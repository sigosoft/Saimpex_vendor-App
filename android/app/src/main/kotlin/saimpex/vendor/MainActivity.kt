package saimpex.vendor

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import java.util.UUID

class MainActivity : FlutterActivity() {
    private val channelName = "saimpex.vendor/escpos_printer"
    private val sppUuid: UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "printEscPos" -> {
                    val address = call.argument<String>("address")
                    val data = call.argument<List<Int>>("bytes")

                    if (data.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "Print bytes are empty", null)
                        return@setMethodCallHandler
                    }
                    if (!hasBluetoothConnectPermission()) {
                        result.error("NO_BT_PERMISSION", "Bluetooth permission not granted", null)
                        return@setMethodCallHandler
                    }

                    val bytes = ByteArray(data.size)
                    data.forEachIndexed { index, value ->
                        bytes[index] = value.toByte()
                    }

                    Thread {
                        try {
                            val connectedAddress = printEscPos(address, bytes)
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
    private fun printEscPos(address: String?, payload: ByteArray): String {
        val adapter = BluetoothAdapter.getDefaultAdapter()
            ?: throw IOException("Bluetooth adapter not available")
        if (!adapter.isEnabled) {
            throw IOException("Bluetooth is disabled")
        }

        val targets = mutableListOf<BluetoothDevice>()

        if (!address.isNullOrBlank()) {
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
            throw IOException("No paired Bluetooth printer/device found")
        }

        var lastError: Exception? = null
        for (device in targets) {
            var socket: BluetoothSocket? = null
            try {
                adapter.cancelDiscovery()
                socket = device.createRfcommSocketToServiceRecord(sppUuid)
                socket.connect()

                val output = socket.outputStream
                output.write(payload)
                output.flush()
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
