import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

class InterventionCard extends StatelessWidget {
  final Intervention intervention;
  final bool selected;
  final bool showCheckbox;
  final Function() onTap;

  const InterventionCard(this.intervention, {this.onTap, this.selected = false, this.showCheckbox = true, Key key})
      : super(key: key);
  String scheduleString(List<Schedule> schedules) {
    return schedules.map((schedule) {
      switch (schedule.runtimeType) {
        case FixedSchedule:
          final FixedSchedule fixedSchedule = schedule;
          return fixedSchedule.time.toString();

        default:
          print('Schedule not supported!');
          return '';
      }
    }).join(',');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: showCheckbox ? onTap : null,
          leading: Icon(MdiIcons.fromString(intervention.icon)),
          trailing: showCheckbox
              ? Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(), // Needed so Checkbox can be clicked and has color
                )
              : null,
          dense: true,
          title: Text(
            intervention.name,
            style: theme.textTheme.headline6,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            intervention.description ?? '',
            style: theme.textTheme.bodyText2.copyWith(color: theme.textTheme.caption.color),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Daily Tasks:', style: theme.textTheme.bodyText2),
        ),
        Divider(
          height: 4,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: intervention.tasks
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: Text(task.title, style: theme.textTheme.bodyText2)),
                      FittedBox(
                          child: Text(
                        scheduleString(task.schedule),
                        style: theme.textTheme.bodyText2.copyWith(fontSize: 12, color: theme.textTheme.caption.color),
                      )),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
