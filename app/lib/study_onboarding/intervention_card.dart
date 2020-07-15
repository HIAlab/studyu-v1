import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nof1_models/models/models.dart';

class InterventionCard extends StatelessWidget {
  final Intervention intervention;
  final bool selected;
  final Function() onTap;

  const InterventionCard(this.intervention, {this.onTap, this.selected = false, Key key}) : super(key: key);
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
    return Card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(MdiIcons.fromString(intervention.icon)),
          trailing: Checkbox(
            value: selected,
            onChanged: null,
          ),
          dense: true,
          title: Text(
            intervention.name,
            style: theme.textTheme.headline6,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            intervention.description,
            style: theme.textTheme.bodyText2.copyWith(color: theme.textTheme.caption.color),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Daily Tasks:'),
        ),
        Divider(
          height: 4,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: intervention.tasks.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(child: Text(intervention.tasks[index].title)),
                FittedBox(
                    child: Text(
                  scheduleString(intervention.tasks[index].schedule),
                  style: theme.textTheme.bodyText2.copyWith(fontSize: 12, color: theme.textTheme.caption.color),
                )),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}