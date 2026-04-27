package saimpex.vendor

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.app.PendingIntent
import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.net.InetSocketAddress
import java.net.Socket
import java.util.UUID
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val channelName = "saimpex.vendor/escpos_printer"
    private val sppUuid: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "printEscPos" -> {
                    val address = call.argument<String>("address")
                    val data80 = call.argument<List<Int>>("bytes80mm")
                    val data58 = call.argument<List<Int>>("bytes58mm")

                    if (data80.isNullOrEmpty() || data58.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "Print bytes are empty", null)
                        return@setMethodCallHandler
                    }
                    if (!hasBluetoothConnectPermission()) {
                        result.error("NO_BT_PERMISSION", "Bluetooth permission not granted", null)
                        return@setMethodCallHandler
                    }

                    val bytes80 = ByteArray(data80.size)
                    data80.forEachIndexed { index, value -> bytes80[index] = value.toByte() }
                    
                    val bytes58 = ByteArray(data58.size)
                    data58.forEachIndexed { index, value -> bytes58[index] = value.toByte() }

                    Thread {
                        try {
                            val connectedAddress = printEscPos(address, bytes80, bytes58)
                            runOnUiThread { result.success(connectedAddress) }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error("PRINT_FAILED", e.message ?: "Print failed", null)
                            }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasBluetoothConnectPermission(): Boolean {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    @SuppressLint("MissingPermission")
    @Throws(IOException::class)
    private fun printEscPos(address: String?, payload80: ByteArray, payload58: ByteArray): String {
        val isIpAddress = address != null && address.matches(Regex("^\\d{1,3}(\\.\\d{1,3}){3}$"))
        val isMacAddress = address != null && address.matches(Regex("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"))

        // 1. LAN / NETWORK PRINTER
        if (isIpAddress) {
            return printNetwork(address!!, payload80) // Desktop LAN printers are typically 80mm
        }

        // 2. USB PRINTER
        val usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        val usbDevices = usbManager.deviceList
        var foundUsbDevice: UsbDevice? = null
        for ((_, device) in usbDevices) {
            val isPrinter = (0 until device.interfaceCount).any { i ->
                device.getInterface(i).interfaceClass == UsbConstants.USB_CLASS_PRINTER
            }
            if (isPrinter) {
                foundUsbDevice = device
                break
            }
        }

        // If a USB printer is physically connected, prioritize it unless a MAC address was strictly provided
        if (foundUsbDevice != null && !isMacAddress) {
            return printUsb(usbManager, foundUsbDevice, payload80, payload58)
        }

        // 3. BLUETOOTH PRINTER (Fallback)
        return printBluetooth(address, payload80, payload58)
    }

    private fun printNetwork(ipAddress: String, payload: ByteArray): String {
        var socket: Socket? = null
        try {
            socket = Socket()
            socket.connect(InetSocketAddress(ipAddress, 9100), 5000)
            val output = socket.getOutputStream()
            output.write(payload)
            output.flush()
            Thread.sleep(200)
            return ipAddress
        } catch (e: Exception) {
            throw IOException("LAN Print Failed: ${e.message}")
        } finally {
            try { socket?.close() } catch (e: Exception) {}
        }
    }

    private val ACTION_USB_PERMISSION = "com.saimpex.vendor.USB_PERMISSION"

    private fun printUsb(usbManager: UsbManager, device: UsbDevice, payload80: ByteArray, payload58: ByteArray): String {
        val intf = (0 until device.interfaceCount)
            .map { device.getInterface(it) }
            .firstOrNull { it.interfaceClass == UsbConstants.USB_CLASS_PRINTER }
            ?: throw IOException("No USB Printer interface found")

        val endpoint = (0 until intf.endpointCount)
            .map { intf.getEndpoint(it) }
            .firstOrNull { it.direction == UsbConstants.USB_DIR_OUT }
            ?: throw IOException("No USB OUT endpoint found")

        if (!usbManager.hasPermission(device)) {
            val latch = CountDownLatch(1)
            var permissionGranted = false

            val receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    if (ACTION_USB_PERMISSION == intent.action) {
                        synchronized(this) {
                            val deviceExtra: UsbDevice? = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                            if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                                if (deviceExtra?.deviceName == device.deviceName) {
                                    permissionGranted = true
                                }
                            }
                            latch.countDown()
                        }
                    }
                }
            }

            val filter = IntentFilter(ACTION_USB_PERMISSION)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(receiver, filter)
            }

            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0
            val permissionIntent = PendingIntent.getBroadcast(this, 0, Intent(ACTION_USB_PERMISSION), flags)
            usbManager.requestPermission(device, permissionIntent)

            latch.await(10, TimeUnit.SECONDS)
            unregisterReceiver(receiver)

            if (!permissionGranted) {
                throw IOException("USB permission denied by user")
            }
        }

        val connection = usbManager.openDevice(device) ?: throw IOException("Could not open USB device")
        try {
            connection.claimInterface(intf, true)

            val dName = device.productName?.lowercase() ?: ""
            val is58mm = dName.contains("58") || dName.contains("mtp") || dName.contains("rp58") || dName.contains("pos-58")
            val payloadToPrint = if (is58mm) payload58 else payload80

            // Chunk the payload for USB bulk transfer
            val chunkSize = 16384
            var offset = 0
            while (offset < payloadToPrint.size) {
                val size = minOf(chunkSize, payloadToPrint.size - offset)
                val chunk = payloadToPrint.sliceArray(offset until offset + size)
                val result = connection.bulkTransfer(endpoint, chunk, chunk.size, 5000)
                if (result < 0) throw IOException("USB transfer failed at offset $offset")
                offset += size
            }
            return "USB_${device.deviceName}"
        } finally {
            connection.releaseInterface(intf)
            connection.close()
        }
    }

    @SuppressLint("MissingPermission")
    private fun printBluetooth(address: String?, payload80: ByteArray, payload58: ByteArray): String {
        val adapter = BluetoothAdapter.getDefaultAdapter()
            ?: throw IOException("Bluetooth adapter not available")
        if (!adapter.isEnabled) {
            throw IOException("Bluetooth is disabled")
        }

        val targets = mutableListOf<BluetoothDevice>()

        if (!address.isNullOrBlank() && address.matches(Regex("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"))) {
            val specific = try {
                adapter.getRemoteDevice(address)
            } catch (e: IllegalArgumentException) {
                throw IOException("Invalid printer address")
            }
            targets.add(specific)
        } else {
            val bonded = adapter.bondedDevices?.toList() ?: emptyList()
            targets.addAll(bonded)
        }

        if (targets.isEmpty()) {
            throw IOException("No paired Bluetooth printer found")
        }

        var lastError: Exception? = null
        for (device in targets) {
            var socket: BluetoothSocket? = null
            try {
                adapter.cancelDiscovery()
                
                socket = try {
                    device.createRfcommSocketToServiceRecord(sppUuid)
                } catch (e: Exception) {
                    device.createInsecureRfcommSocketToServiceRecord(sppUuid)
                }
                
                try {
                    socket?.connect()
                } catch (e: Exception) {
                    socket?.close()
                    socket = device.createInsecureRfcommSocketToServiceRecord(sppUuid)
                    socket.connect()
                }

                val output = socket?.outputStream ?: throw IOException("Unable to get output stream")
                
                val dName = device.name?.lowercase() ?: ""
                val is58mm = dName.contains("58") || 
                             dName.contains("mtp") || 
                             dName.contains("innerprinter") || 
                             dName.contains("sunmi") || 
                             dName.contains("rp58") || 
                             dName.contains("pos-58")
                             
                val payloadToPrint = if (is58mm) payload58 else payload80
                
                output.write(payloadToPrint)
                output.flush()
                
                Thread.sleep(200)
                
                return device.address
            } catch (e: Exception) {
                lastError = e
            } finally {
                try {
                    socket?.close()
                } catch (_: Exception) {
                }
            }
        }

        throw IOException(lastError?.message ?: "Unable to connect to any paired Bluetooth device")
    }
}
