import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saimpex_vendor/configs/ApiConfigs.dart';
import 'package:saimpex_vendor/controller/profile_controller.dart';
import 'package:saimpex_vendor/generated/l10n.dart';
import 'package:saimpex_vendor/model/profile_model.dart';
import 'package:saimpex_vendor/utils/widgets/app_loader.dart';
import 'package:saimpex_vendor/utils/widgets/custom_search_box.dart';

import '../../../Utils/Utils.dart';

class VendorWorkingHoursList extends StatelessWidget {
  final void Function(int dayIndex, WorkingHour hour)? onEditDay;
  final void Function(WorkingHour hour, WorkingTimeSlot slot)? onDeleteSlot;

  const VendorWorkingHoursList({super.key, this.onEditDay, this.onDeleteSlot});

  @override
  Widget build(BuildContext context) {
    final days = [
      S.of(context).monday,
      S.of(context).tuesday,
      S.of(context).wednesday,
      S.of(context).thursday,
      S.of(context).friday,
      S.of(context).saturday,
      S.of(context).sunday,
    ];

    return GetBuilder<ProfileController>(
      builder: (profileController) {
        return Column(
          children: List.generate(days.length, (dayIndex) {
            final dayLabel = days[dayIndex];
            final hour = _findWorkingHourForDay(
              profileController.workingHours,
              dayIndex,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      dayLabel,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _daySlotWidgets(
                        context,
                        hour,
                        dayIndex,
                        dayLabel,
                        profileController,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  List<Widget> _daySlotWidgets(
    BuildContext context,
    WorkingHour? hour,
    int dayIndex,
    String dayLabel,
    ProfileController profileController,
  ) {
    if (hour == null || hour.isClosed == true) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '-',
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ];
    }

    if (hour.status != null && hour.status == 0) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '-',
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ];
    }

    if (hour.isOpen24h == 1) {
      return [
        _timePillRow(
          label: S.of(context).hr24,
          pillColor: const Color(0xFFEFF2FF),
          pillTextColor: const Color(0xFF4B5563),
          actionIcon: Icons.edit_outlined,
          actionColor: const Color(0xFFFF5216),
          onActionPressed: () {
            if (onEditDay != null) {
              onEditDay!(dayIndex, hour);
              return;
            }
            _showEditWorkingHourDialog(
              context,
              dayLabel: dayLabel,
              profileController: profileController,
              dayId: dayIndex + 1,
              initialIsOpen24: true,
              initialStartTime: hour.openingTime,
              initialEndTime: hour.closingTime,
              initialTimeSlots: hour.timeSlots,
              currentHour: hour,
            );
          },
        ),
      ];
    }

    // Non-24h: show one pill per slot (Monday screenshot shows multiple).
    final nonNullHour = hour;

    final slots =
        (nonNullHour.timeSlots != null && nonNullHour.timeSlots!.isNotEmpty)
        ? nonNullHour.timeSlots!
        : [
            WorkingTimeSlot(
              id: null,
              vendorWorkingHourId: nonNullHour.id,
              openTime: nonNullHour.openingTime,
              closeTime: nonNullHour.closingTime,
            ),
          ];

    return List.generate(slots.length, (index) {
      final slot = slots[index];
      final rangeLabel = _timeRangeLabel(hour: nonNullHour, slot: slot);
      return Padding(
        padding: EdgeInsets.only(bottom: index == slots.length - 1 ? 0 : 8),
        child: _timePillRow(
          label: rangeLabel,
          pillColor: const Color(0xFFEFF2FF),
          pillTextColor: const Color(0xFF4B5563),
          actionIcon: Icons.delete_outline,
          actionColor: const Color(0xFFEF4444),
          onActionPressed: () {
            if (onDeleteSlot != null) {
              onDeleteSlot!(nonNullHour, slot);
              return;
            }
            // Default behavior: remove current time slot UI and reset day to 24h.
            _resetDayTo24Hours(
              profileController: profileController,
              dayIndex: dayIndex,
              currentHour: nonNullHour,
            );

            // Persist the change to backend: reset day to 24h with empty hours.
            // This will build the payload from updated `profileController.workingHours`.
            profileController.uploadWorkingHours(context);
          },
        ),
      );
    });
  }

  void _resetDayTo24Hours({
    required ProfileController profileController,
    required int dayIndex,
    required WorkingHour? currentHour,
  }) {
    if (currentHour == null) return;

    final apiDay = dayIndex + 1; // Backend format: 1=Mon ... 7=Sun.

    // Prefer matching by id when present, otherwise by dayOfWeek.
    final targetIndex = profileController.workingHours.indexWhere((h) {
      if (currentHour.id != null && h.id == currentHour.id) return true;
      return (h.dayOfWeek ?? 0) == apiDay;
    });

    if (targetIndex < 0) return;

    final original = profileController.workingHours[targetIndex];
    final updated = WorkingHour(
      id: original.id,
      day: original.day,
      dayOfWeek: original.dayOfWeek ?? apiDay,
      isOpen24h: 1,
      status: (original.status != null && original.status == 0)
          ? 1
          : original.status,
      openingTime: original.openingTime ?? '00:00',
      closingTime: original.closingTime ?? '23:59',
      isClosed: false,
      timeSlots: const [],
    );

    profileController.workingHours[targetIndex] = updated;
    profileController.update();
  }

  Future<void> _showEditWorkingHourDialog(
    BuildContext context, {
    required String dayLabel,
    required ProfileController profileController,
    required int dayId,
    required bool initialIsOpen24,
    String? initialStartTime,
    String? initialEndTime,
    List<WorkingTimeSlot>? initialTimeSlots,
    WorkingHour? currentHour,
  }) async {
    final startMinutes =
        _parseToMinutes(initialStartTime ?? '') ?? (0 * 60); // 00:00
    final endMinutes =
        _parseToMinutes(initialEndTime ?? '') ?? (23 * 60 + 59); // 23:59

    final defaultStartText = _formatMinutesHHmm(startMinutes);
    final defaultEndText = _formatMinutesHHmm(endMinutes);

    String _maybeFormatSlot(String? raw) {
      final mins = _parseToMinutes(raw ?? '');
      if (mins == null) return '';
      return _formatMinutesHHmm(mins);
    }

    // If Open 24 Hr is disabled initially (or user disables it), prefill slots
    // from API timeSlots; otherwise fall back to opening/closing time.
    final initialSlotDrafts = (!initialIsOpen24)
        ? (initialTimeSlots != null && initialTimeSlots.isNotEmpty)
              ? initialTimeSlots
                    .take(3)
                    .map(
                      (slot) => {
                        'start': _maybeFormatSlot(slot.openTime),
                        'end': _maybeFormatSlot(slot.closeTime),
                      },
                    )
                    .toList()
              : [
                      {
                        'start': _maybeFormatSlot(initialStartTime),
                        'end': _maybeFormatSlot(initialEndTime),
                      },
                    ]
                    .where(
                      (m) =>
                          (m['start'] ?? '').isNotEmpty ||
                          (m['end'] ?? '').isNotEmpty,
                    )
                    .toList()
        : <Map<String, String>>[];

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool isOpen24 = initialIsOpen24;
        String startTime = defaultStartText;
        String endTime = defaultEndText;
        List<Map<String, String>> slotDrafts = initialSlotDrafts
            .map(
              (m) => <String, String>{
                'start': m['start'] ?? '',
                'end': m['end'] ?? '',
              },
            )
            .toList();

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Widget timeBox({
              required String value,
              required bool enabled,
              required VoidCallback? onTap,
            }) {
              return InkWell(
                onTap: enabled ? onTap : null,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    value,
                    style: GoogleFonts.rubik(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
              );
            }

            Future<void> pickTime({required bool isStart}) async {
              final parts = (isStart ? startTime : endTime).split(':');
              final h = int.tryParse(parts[0]) ?? 0;
              final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
              final picked = await showTimePicker(
                context: dialogContext,
                initialTime: TimeOfDay(hour: h, minute: m),
              );
              if (picked == null) return;
              setState(() {
                final newText =
                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                if (isStart) {
                  startTime = newText;
                } else {
                  endTime = newText;
                }
              });
            }

            Future<void> pickSlotTime({
              required int slotIndex,
              required bool isStart,
            }) async {
              final current = isStart
                  ? (slotDrafts[slotIndex]['start'] ?? '')
                  : (slotDrafts[slotIndex]['end'] ?? '');
              final parts = current.split(':');
              final h = int.tryParse(parts[0]) ?? 0;
              final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
              final picked = await showTimePicker(
                context: dialogContext,
                initialTime: TimeOfDay(hour: h, minute: m),
              );
              if (picked == null) return;
              setState(() {
                final newText =
                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                if (isStart) {
                  slotDrafts[slotIndex]['start'] = newText;
                } else {
                  slotDrafts[slotIndex]['end'] = newText;
                }
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit Working Hour",
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dayLabel,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: isOpen24,
                          activeColor: const Color(0xFFFF5216),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              isOpen24 = v;
                              if (!isOpen24) {
                                // Show first empty slot immediately (matches your screenshot).
                                if (slotDrafts.isEmpty) {
                                  final slotStart = _maybeFormatSlot(
                                    initialStartTime,
                                  );
                                  final slotEnd = _maybeFormatSlot(
                                    initialEndTime,
                                  );
                                  slotDrafts =
                                      [
                                            {
                                              'start': slotStart,
                                              'end': slotEnd,
                                            },
                                          ]
                                          .where(
                                            (m) =>
                                                (m['start'] ?? '').isNotEmpty ||
                                                (m['end'] ?? '').isNotEmpty,
                                          )
                                          .toList();
                                }
                              }
                            });
                          },
                        ),
                        Text(
                          "Open 24 Hr",
                          style: GoogleFonts.rubik(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (isOpen24)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start Time",
                                  style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                timeBox(
                                  value: startTime,
                                  enabled: !isOpen24,
                                  onTap: () {
                                    pickTime(isStart: true);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "End Time",
                                  style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                timeBox(
                                  value: endTime,
                                  enabled: !isOpen24,
                                  onTap: () {
                                    pickTime(isStart: false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (slotDrafts.isEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (slotDrafts.length >= 3) return;
                                  slotDrafts.add({'start': '', 'end': ''});
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFFF5216),
                                  width: 1,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width,
                                  44,
                                ),
                              ),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Color(0xFFFF5216),
                              ),
                              label: Text(
                                "+ Add Time Slot",
                                style: GoogleFonts.rubik(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFF5216),
                                ),
                              ),
                            )
                          else
                            ...List.generate(slotDrafts.length, (slotIndex) {
                              final slotStart =
                                  slotDrafts[slotIndex]['start'] ?? '';
                              final slotEnd =
                                  slotDrafts[slotIndex]['end'] ?? '';
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Start Time",
                                              style: GoogleFonts.rubik(
                                                fontSize: 12,
                                                color: const Color(0xFF6B7280),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            timeBox(
                                              value: slotStart,
                                              enabled: true,
                                              onTap: () {
                                                pickSlotTime(
                                                  slotIndex: slotIndex,
                                                  isStart: true,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "End Time",
                                              style: GoogleFonts.rubik(
                                                fontSize: 12,
                                                color: const Color(0xFF6B7280),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            timeBox(
                                              value: slotEnd,
                                              enabled: true,
                                              onTap: () {
                                                pickSlotTime(
                                                  slotIndex: slotIndex,
                                                  isStart: false,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (slotIndex < slotDrafts.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              );
                            }),
                          if (slotDrafts.isNotEmpty && slotDrafts.length < 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    if (slotDrafts.length >= 3) return;
                                    slotDrafts.add({'start': '', 'end': ''});
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFFF5216),
                                    width: 1,
                                  ),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  minimumSize: Size(
                                    MediaQuery.of(context).size.width,
                                    44,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: Color(0xFFFF5216),
                                ),
                                label: Text(
                                  "+ Add Time Slot",
                                  style: GoogleFonts.rubik(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF5216),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE5E7EB),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.rubik(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                // Convert dialog values into WorkingHour model,
                                // update controller state, then upload to API.
                                final existingIndex = profileController
                                    .workingHours
                                    .indexWhere((h) {
                                      if (currentHour?.id != null &&
                                          h.id == currentHour!.id) {
                                        return true;
                                      }
                                      return (h.dayOfWeek ?? 0) == dayId;
                                    });

                                final existingHour = existingIndex >= 0
                                    ? profileController
                                          .workingHours[existingIndex]
                                    : currentHour;

                                List<WorkingTimeSlot> validSlots = [];
                                String fallbackOpen = startTime;
                                String fallbackClose = endTime;

                                if (!isOpen24) {
                                  final filtered = slotDrafts
                                      .take(3)
                                      .where(
                                        (m) =>
                                            (m['start'] ?? '').isNotEmpty &&
                                            (m['end'] ?? '').isNotEmpty,
                                      )
                                      .toList();

                                  validSlots = filtered
                                      .map(
                                        (m) => WorkingTimeSlot(
                                          id: null,
                                          vendorWorkingHourId: existingHour?.id,
                                          openTime: m['start'],
                                          closeTime: m['end'],
                                        ),
                                      )
                                      .toList();

                                  if (validSlots.isEmpty) {
                                    showToast(
                                      context,
                                      "Please add at least one valid time slot.",
                                    );
                                    return;
                                  }

                                  fallbackOpen =
                                      validSlots.first.openTime ?? startTime;
                                  fallbackClose =
                                      validSlots.first.closeTime ?? endTime;
                                }

                                final updatedHour = WorkingHour(
                                  id: existingHour?.id,
                                  day: existingHour?.day,
                                  dayOfWeek: dayId,
                                  isOpen24h: isOpen24 ? 1 : 2,
                                  status: existingHour?.status,
                                  openingTime: fallbackOpen,
                                  closingTime: fallbackClose,
                                  isClosed: false,
                                  timeSlots: isOpen24
                                      ? <WorkingTimeSlot>[]
                                      : validSlots,
                                );

                                if (existingIndex >= 0) {
                                  profileController
                                          .workingHours[existingIndex] =
                                      updatedHour;
                                } else {
                                  profileController.workingHours.add(
                                    updatedHour,
                                  );
                                }

                                profileController.update();

                                await profileController.uploadWorkingHours(
                                  dialogContext,
                                );

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5216),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                "Save",
                                style: GoogleFonts.rubik(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _timePillRow({
    required String label,
    required Color pillColor,
    required Color pillTextColor,
    required IconData actionIcon,
    required Color actionColor,
    VoidCallback? onActionPressed,
  }) {
    final Widget actionWidget;
    if (onActionPressed == null) {
      actionWidget = Icon(actionIcon, size: 18, color: actionColor);
    } else {
      actionWidget = IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        icon: Icon(actionIcon, size: 18, color: actionColor),
        onPressed: onActionPressed,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: pillTextColor,
            ),
          ),
        ),
        const SizedBox(width: 10),
        actionWidget,
      ],
    );
  }

  WorkingHour? _findWorkingHourForDay(List<WorkingHour> hours, int dayIndex) {
    if (hours.isEmpty) return null;
    final apiDay = dayIndex + 1; // Backend format: 1=Mon ... 7=Sun.

    for (final hour in hours) {
      if (hour.dayOfWeek == apiDay) return hour;
    }

    // Fallback for APIs that return Monday..Sunday in order.
    if (hours.length > dayIndex &&
        (hours[dayIndex].day?.trim().isEmpty ?? true)) {
      return hours[dayIndex];
    }

    const aliases = [
      ['mon', 'monday', '1'],
      ['tue', 'tuesday', '2'],
      ['wed', 'wednesday', '3'],
      ['thu', 'thursday', '4'],
      ['fri', 'friday', '5'],
      ['sat', 'saturday', '6'],
      ['sun', 'sunday', '7'],
    ];
    final dayAliases = aliases[dayIndex];

    for (final hour in hours) {
      final rawDay = (hour.day ?? '').toLowerCase().trim();
      if (rawDay.isEmpty) continue;
      if (dayAliases.any(
        (alias) => rawDay == alias || rawDay.contains(alias),
      )) {
        return hour;
      }
    }

    // Last fallback by position if mapping fails.
    if (hours.length > dayIndex) return hours[dayIndex];
    return null;
  }

  String _timeRangeLabel({
    required WorkingHour hour,
    required WorkingTimeSlot slot,
  }) {
    // Prefer slot-specific values, fallback to day values.
    final openInput = (slot.openTime ?? hour.openingTime)?.trim();
    final closeInput = (slot.closeTime ?? hour.closingTime)?.trim();

    int? openMinutes = _parseToMinutes(openInput);
    int? closeMinutes = _parseToMinutes(closeInput);

    // Some APIs provide a single "open-close" range in one field.
    if (openMinutes == null || closeMinutes == null) {
      final rangeFromOpen = _parseRangeFromText(openInput);
      if (rangeFromOpen != null) {
        openMinutes ??= rangeFromOpen[0];
        closeMinutes ??= rangeFromOpen[1];
      }
    }
    if (openMinutes == null || closeMinutes == null) {
      final rangeFromClose = _parseRangeFromText(closeInput);
      if (rangeFromClose != null) {
        openMinutes ??= rangeFromClose[0];
        closeMinutes ??= rangeFromClose[1];
      }
    }

    if (openMinutes != null && closeMinutes != null) {
      final open = _formatMinutesHHmm(openMinutes);
      final close = _formatMinutesHHmm(closeMinutes);
      return '$open - $close';
    }

    if ((openInput ?? '').isNotEmpty && (closeInput ?? '').isNotEmpty) {
      return '$openInput - $closeInput';
    }
    return '-';
  }

  String _formatMinutesHHmm(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  int? _parseToMinutes(String? value) {
    if (value == null) return null;
    final input = value.trim().toLowerCase();
    if (input.isEmpty) return null;

    // Strict match: "09:30", "09:30:00", "9:30 am", "09:30 pm", "9 pm".
    final strictMatch = RegExp(
      r'^(\d{1,2})(?::(\d{1,2}))?(?::\d{1,2})?\s*(am|pm)?$',
      caseSensitive: false,
    ).firstMatch(input);
    if (strictMatch != null) return _matchToMinutes(strictMatch);

    // Fallback: extract first time-like token from date/range text.
    final tokenMatch = RegExp(
      r'(\d{1,2}(?::\d{1,2})?(?::\d{1,2})?\s*(?:am|pm)?)',
      caseSensitive: false,
    ).firstMatch(input);
    if (tokenMatch == null) return null;
    final token = tokenMatch.group(1)?.trim().toLowerCase();
    if (token == null || token.isEmpty) return null;

    final match = RegExp(
      r'^(\d{1,2})(?::(\d{1,2}))?(?::\d{1,2})?\s*(am|pm)?$',
      caseSensitive: false,
    ).firstMatch(token);
    if (match == null) return null;

    return _matchToMinutes(match);
  }

  int? _matchToMinutes(RegExpMatch match) {
    int hour = int.tryParse(match.group(1) ?? '') ?? -1;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final period = match.group(3)?.toLowerCase();

    if (minute < 0 || minute > 59) return null;
    if (period == null) {
      if (hour < 0 || hour > 23) return null;
      return hour * 60 + minute;
    }

    if (hour < 1 || hour > 12) return null;
    if (period == 'am') {
      if (hour == 12) hour = 0;
    } else if (period == 'pm') {
      if (hour != 12) hour += 12;
    }
    return hour * 60 + minute;
  }

  List<int>? _parseRangeFromText(String? value) {
    if (value == null) return null;
    final input = value.trim();
    if (input.isEmpty) return null;

    final matches = RegExp(
      r'(\d{1,2}(?::\d{1,2})?(?::\d{1,2})?\s*(?:am|pm)?)',
      caseSensitive: false,
    ).allMatches(input).toList();

    if (matches.length < 2) return null;

    final first = _parseToMinutes(matches[0].group(1));
    final second = _parseToMinutes(matches[1].group(1));
    if (first == null || second == null) return null;
    return [first, second];
  }
}

class VendorSectionHeader extends StatelessWidget {
  final String title;

  const VendorSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    String localizedTitle = title;
    if (title == "RESTAURANT DETAILS") {
      localizedTitle = S.of(context).restaurantDetails;
    } else if (title == "BANK DETAILS") {
      localizedTitle = S.of(context).bankDetails;
    } else if (title == "ABOUT THE RESTAURANT") {
      localizedTitle = S.of(context).aboutTheRestaurant;
    } else if (title == "REGISTRATION DETAILS") {
      localizedTitle = S.of(context).registrationDetails;
    } else if (title == "PAYMENT DETAILS") {
      localizedTitle = S.of(context).paymentSummaryDetails;
    } else if (title == "OWNER IDENTITY PROOF") {
      localizedTitle = S.of(context).ownerIdentityProof;
    } else if (title == "CERTIFICATES") {
      localizedTitle = S.of(context).certificates;
    } else if (title == "RATING & REVIEWS") {
      localizedTitle = S.of(context).ratingReviews;
    } else if (title == "MARK LEAVE") {
      localizedTitle = S.of(context).markLeave;
    } else if (title == "LEAVES HISTORY") {
      localizedTitle = S.of(context).leavesHistory;
    } else if (title == "WORKING HOURS") {
      localizedTitle = S.of(context).workingHours;
    } else if (title == "ALL MENUS") {
      localizedTitle = S.of(context).allMenus;
    } else if (title == "ALL ITEMS") {
      localizedTitle = S.of(context).allItems;
    } else if (title == "MENU BULK IMPORT") {
      localizedTitle = S.of(context).menuBulkImport;
    } else if (title == "BASKETS") {
      localizedTitle = S.of(context).basket;
    } else if (title == "RECEIVED PAYOUTS") {
      localizedTitle = S.of(context).receivedPayouts;
    } else if (title == "STORE REPORTS") {
      localizedTitle = S.of(context).storeReports;
    }

    return Text(
      localizedTitle,
      style: GoogleFonts.rubik(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F1F1F),
      ),
    );
  }
}

class VendorDetailCard extends StatelessWidget {
  final double? height;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const VendorDetailCard({
    super.key,
    this.height,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: child,
    );
  }
}

class VendorDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  final bool isBoldValue;

  const VendorDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isStatus = false,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    String localizedLabel = label;
    if (label == "Name") localizedLabel = S.of(context).name;
    if (label == "Owner") localizedLabel = S.of(context).owner;
    if (label == "ID") localizedLabel = S.of(context).idNumber;
    if (label == "Contact") localizedLabel = S.of(context).contact;
    if (label == "Email") localizedLabel = S.of(context).email;
    if (label == "Status") localizedLabel = S.of(context).status;
    if (label == "Address") localizedLabel = S.of(context).address;
    if (label == "Holder Name") localizedLabel = S.of(context).holderName;
    if (label == "IBAN Number") localizedLabel = S.of(context).ibanNumber;
    if (label == "SWIFT Code") localizedLabel = S.of(context).swiftCode;
    if (label == "Category") localizedLabel = S.of(context).categoryLabel;
    if (label == "Reg. Number") localizedLabel = S.of(context).regNumber;
    if (label == "Reg. Date") localizedLabel = S.of(context).regDate;
    if (label == "GST Number") localizedLabel = S.of(context).gstNumber;
    if (label == "Commission %") {
      localizedLabel = S.of(context).commissionPercentage;
    }
    if (label == "Total Profit") localizedLabel = S.of(context).totalProfit;
    if (label == "Service Delivery Charge") {
      localizedLabel = S.of(context).serviceDeliveryCharge;
    }
    if (label == "Restaurant Commission Percentage per Order") {
      localizedLabel = S.of(context).restaurantCommission;
    }
    if (label == "Gst/Vat") localizedLabel = S.of(context).gstVat;
    if (label == "Packaging Cost") localizedLabel = S.of(context).packagingCost;
    if (label == "Bank Name") localizedLabel = S.of(context).bankName;
    if (label == "Account Name") localizedLabel = S.of(context).accountName;
    if (label == "Account Number") localizedLabel = S.of(context).accountNumber;
    if (label == "Trade License No") {
      localizedLabel = S.of(context).tradeLicenseNo;
    }
    if (label == "Vat/Gst Number") localizedLabel = S.of(context).vatGstNumber;
    if (label == "National Id Type") {
      localizedLabel = S.of(context).nationalIdType;
    }
    if (label == "National Id Number") {
      localizedLabel = S.of(context).nationalIdNumber;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              localizedLabel,
              style: GoogleFonts.rubik(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Text(
                value,
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF166534),
                ),
              ),
            )
          else
            Expanded(
              flex: 2,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.end,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w500,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class VendorImageCard extends StatelessWidget {
  final double? height;
  final String? imageUrl;

  const VendorImageCard({super.key, this.height, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final String? fullUrl = imageUrl != null && imageUrl!.isNotEmpty
        ? (imageUrl!.startsWith('http')
              ? imageUrl
              : '${ApiConfigs.IMAGE_URL}$imageUrl')
        : null;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: height ?? MediaQuery.of(context).size.height * 0.14,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: fullUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                fullUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 36,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const AppLoader();
                },
              ),
            )
          : const Center(
              child: Icon(
                Icons.image_outlined,
                color: Color(0xFF9CA3AF),
                size: 36,
              ),
            ),
    );
  }
}

class VendorReviewItem extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String review;
  final String orderId;

  const VendorReviewItem({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.review,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.18,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFDCFCE7),
                child: Text(
                  name.isNotEmpty ? name[0] : "",
                  style: GoogleFonts.rubik(
                    color: const Color(0xFF166534),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: const Color(0xFFF59E0B),
                              size: 14,
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.rubik(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatOrderPlacedAt(DateTime.parse(date.toString())),
                style: GoogleFonts.rubik(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: GoogleFonts.rubik(
              fontSize: 13,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  S.of(context).orderColon,
                  style: GoogleFonts.rubik(
                    fontSize: 11,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    orderId,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VendorLeaveTile extends StatelessWidget {
  final String dateRange;
  final String reason;
  final String status;
  final bool isUpcoming;
  final VoidCallback? onCancelLeave;

  const VendorLeaveTile({
    super.key,
    required this.dateRange,
    required this.reason,
    required this.status,
    required this.isUpcoming,
    this.onCancelLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateRange,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    Text(
                      reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 10,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? const Color(0xFFEEF2FF)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.rubik(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isUpcoming
                        ? const Color(0xFF4F46E1)
                        : const Color(0xFF166534),
                  ),
                ),
              ),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: onCancelLeave,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFCCBD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  S.of(context).cancelLeave,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF5216),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VendorSearchRow extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const VendorSearchRow({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomSearchBox(
            hintText: S.of(context).searchByIdName,
            boxColor: Colors.white,
            controller: controller,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        // Container(
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: const Color(0xFFF1F5F9)),
        //   ),
        //   child: const Icon(Icons.tune, color: Color(0xFF64748B), size: 24),
        // ),
      ],
    );
  }
}

class VendorCategoryAddRow extends StatelessWidget {
  final List<RestaurantCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?>? onCategoryChanged;
  final VoidCallback onAddPressed;

  const VendorCategoryAddRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.055,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: selectedCategoryId,
                isExpanded: true,
                hint: Text(
                  S.of(context).allCategories,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      S.of(context).allCategories,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(
                        c.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                ],
                onChanged: onCategoryChanged,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: OutlinedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add, color: Color(0xFFFF5216), size: 14),
            label: Text(
              S.of(context).addMenuTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: const Color(0xFFFF5216),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF5216), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows availability label: status 1 = Out of stock, 2 = Available.
class _AvailabilityChip extends StatelessWidget {
  final int status;

  const _AvailabilityChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isAvailable = status == 2;
    final label = isAvailable
        ? S.of(context).availableStatus
        : S.of(context).outOfStock;
    final color = isAvailable
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.rubik(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class VendorRichCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String price;
  final String? originalPrice;
  final String? imageUrl;
  final String itemId;
  final bool isMenu;
  final List<RestaurantCategory>? categories;

  /// 1 = Out of stock, 2 = Available. When null, availability is not shown.
  final int? availabilityStatus;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const VendorRichCard({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    required this.itemId,
    required this.isMenu,
    this.categories,
    this.availabilityStatus,
    required this.onViewDetails,
    required this.onEdit,
    this.onDelete,
  });

  String get _displayCategory {
    if (categories == null || category.isEmpty) return category;
    // Support plain id "7" or API array string "[7]", "['7']", etc.
    int? categoryId = int.tryParse(category.trim());
    if (categoryId == null) {
      final firstNumber = RegExp(r'\d+').firstMatch(category);
      if (firstNumber != null) {
        categoryId = int.tryParse(firstNumber.group(0)!);
      }
    }
    if (categoryId == null) return category;
    try {
      final match = categories!.firstWhere((c) => c.id == categoryId);
      final name = match.name?.trim();
      return (name != null && name.isNotEmpty) ? name : category;
    } catch (_) {
      return category;
    }
  }

  /// Category text to show in the bubble; never empty so the bubble always shows a name.
  String get _displayCategoryLabel {
    final value = _displayCategory.trim();
    return value.isEmpty ? '—' : value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.network(
                                imageUrl!.startsWith('http')
                                    ? imageUrl!
                                    : "${ApiConfigs.IMAGE_URL}$imageUrl",
                                width: MediaQuery.of(context).size.width * 0.22,
                                height:
                                    MediaQuery.of(context).size.width * 0.22,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _VendorDefaultImage(),
                              )
                            : const _VendorDefaultImage(),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ID: # $id",
                          style: GoogleFonts.rubik(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rubik(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1EE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _displayCategoryLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rubik(
                              fontSize: 10,
                              color: const Color(0xFFFF5216),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.rubik(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                            ),
                            if (originalPrice != null) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  originalPrice!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.rubik(
                                    fontSize: 11,
                                    color: const Color(0xFF94A3B8),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                            if (availabilityStatus != null) ...[
                              const SizedBox(width: 12),
                              _AvailabilityChip(status: availabilityStatus!),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.05,
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5216)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    S.of(context).viewDetails,
                    style: GoogleFonts.rubik(
                      color: const Color(0xFFFF5216),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: -8,
            right: -8,
            child: PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Icons.edit_outlined, size: 20),
                    title: Text(
                      S.of(context).edit,
                      style: GoogleFonts.rubik(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                    title: Text(
                      S.of(context).delete,
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorDefaultImage extends StatelessWidget {
  const _VendorDefaultImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.fastfood, color: Color(0xFFFF5216)),
    );
  }
}

class VendorAddNewItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const VendorAddNewItemButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5216),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          S.of(context).addNewItem,
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class VendorBulkImportInstructions extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const VendorBulkImportInstructions({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
            ),
            child: Row(
              children: [
                Text(
                  S.of(context).instructions,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _instructionBlock(
                  index: '1',
                  title: S.of(context).downloadTemplate,
                  body: S
                      .of(context)
                      .downloadTheTemplateFileAndFillItWithProperData,
                ),
                const SizedBox(height: 12),
                _instructionBlock(
                  index: '2',
                  title: S.of(context).selectCategory,
                  body: S
                      .of(context)
                      .onceYouHaveDownloadedAndFilledTheTemplateSelectThe,
                ),
                const SizedBox(height: 12),
                _instructionBlock(
                  index: '3',
                  title: S.of(context).attributesReference,
                  body: S
                      .of(context)
                      .afterAttributesReferenceYouCanEditTheAttributesListBelow,
                ),
                const SizedBox(height: 12),
                _instructionBlock(
                  index: '4',
                  title: S.of(context).postuploadEditing,
                  body: S
                      .of(context)
                      .afterUploadingYouNeedToEditTheItemsIndividuallyTo,
                ),
                const SizedBox(height: 12),
                _instructionBlock(
                  index: '5',
                  title: S.of(context).imageFileNaming,
                  body: S
                      .of(context)
                      .imageFileNamesMustStartWithRestaurantmenusfilenameextensionEgRestaurantmenuspizzajpg,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.of(context).availableAttributes,
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1EE),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFFF5216),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "3 " + "ATTRIBUTES",
                        style: GoogleFonts.rubik(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF5216),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _attributesTable(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

Widget _instructionBlock({
  required String index,
  required String title,
  required String body,
}) {
  return RichText(
    text: TextSpan(
      style: GoogleFonts.rubik(
        fontSize: 13,
        height: 1.6,
        color: const Color(0xFF6B7280),
      ),
      children: [
        TextSpan(
          text: '$index. ',
          style: GoogleFonts.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        TextSpan(
          text: title,
          style: GoogleFonts.rubik(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const TextSpan(text: '\n'),
        TextSpan(text: body),
      ],
    ),
  );
}

Widget _attributesTable() {
  TextStyle headerStyle = GoogleFonts.rubik(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF111827),
  );
  TextStyle valueStyle = GoogleFonts.rubik(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF374151),
  );

  Widget headerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("ID", style: headerStyle),
          Text("NAME", style: headerStyle),
        ],
      ),
    );
  }

  Widget dataRow(String id, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(id, style: valueStyle),
          Text(name, style: valueStyle),
        ],
      ),
    );
  }

  return Container(
    color: Colors.white,
    child: Column(
      children: [
        headerRow(),
        dataRow('1', 'Full'),
        dataRow('2', 'Half'),
        dataRow('4', 'Quarter'),
        const SizedBox(height: 2),
      ],
    ),
  );
}

class VendorImportStep extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;

  const VendorImportStep({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFFF5216),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: GoogleFonts.rubik(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F1F1F),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class VendorBasketItem extends StatelessWidget {
  final String name;
  final String count;
  final String status;

  const VendorBasketItem({
    super.key,
    required this.name,
    required this.count,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return VendorDetailCard(
      height: MediaQuery.of(context).size.height * 0.12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              Text(
                count,
                style: GoogleFonts.rubik(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (status == "Active" || status == S.of(context).activeLabel)
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.rubik(
                fontSize: 12,
                color:
                    (status == "Active" || status == S.of(context).activeLabel)
                    ? const Color(0xFF166534)
                    : const Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VendorPayoutItem extends StatelessWidget {
  final String id;
  final String date;
  final String amount;

  const VendorPayoutItem({
    super.key,
    required this.id,
    required this.date,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return VendorDetailCard(
      height: MediaQuery.of(context).size.height * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                id,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              Text(
                date,
                style: GoogleFonts.rubik(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }
}

class VendorProfileHeaderCard extends StatelessWidget {
  final String name;
  final String rating;

  const VendorProfileHeaderCard({
    super.key,
    required this.name,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.width * 0.2,
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "R1",
                style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF5216),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF166534),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.rubik(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VendorMenuButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const VendorMenuButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  String _getLocalizedMenuTitle(BuildContext context) {
    if (title == "Account") return S.of(context).account;
    if (title == "Working Hours") return S.of(context).workingHours;
    if (title == "Leaves") return S.of(context).leaves;
    if (title == "Menu") return S.of(context).menu;
    if (title == "Items") return S.of(context).items;
    if (title == "Menu Bulk Import") return S.of(context).menuBulkImport;
    if (title == "Basket") return S.of(context).basket;
    if (title == "Received Payouts") return S.of(context).receivedPayouts;
    if (title == "Store Reports") return S.of(context).storeReports;
    return title;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.25,
          minHeight: MediaQuery.of(context).size.height * 0.05,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF5216) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF5216)
                : const Color.fromARGB(255, 200, 202, 203),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            _getLocalizedMenuTitle(context),
            style: GoogleFonts.rubik(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class VendorLeaveForm extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final TextEditingController reasonController;
  final String Function(DateTime?) formatDate;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onMarkLeave;

  const VendorLeaveForm({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.reasonController,
    required this.formatDate,
    required this.onFromTap,
    required this.onToTap,
    required this.onMarkLeave,
  });

  @override
  Widget build(BuildContext context) {
    return VendorDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).fromDate,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onFromTap,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDate(fromDate),
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: Color(0xFF1F1F1F),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).toDate,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onToTap,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDate(toDate),
                              style: GoogleFonts.rubik(
                                fontSize: 13,
                                color: const Color(0xFF1F1F1F),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: Color(0xFF1F1F1F),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).reasonForLeave,
            style: GoogleFonts.rubik(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: MediaQuery.of(context).size.height * 0.12,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: reasonController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: S.of(context).egAnnualVacationRenovation,
                hintStyle: GoogleFonts.rubik(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8).withOpacity(0.6),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: const Color(0xFF1F1F1F),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onMarkLeave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5216),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                S.of(context).markLeave,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
