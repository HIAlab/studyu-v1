import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/expressions/types/boolean_expression.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

import '../models/designer_state.dart';
import '../widgets/designer_add_button.dart';
import '../widgets/eligibility/eligibility_criterion_editor.dart';

class EligibilityDesigner extends StatefulWidget {
  @override
  _EligibilityDesignerState createState() => _EligibilityDesignerState();
}

class _EligibilityDesignerState extends State<EligibilityDesigner> {
  List<EligibilityCriterion> _eligibility;
  List<Question> _questions;

  void _addCriterion() {
    final expression = BooleanExpression();
    final criterion = EligibilityCriterion()
      ..id = Uuid().v4()
      ..condition = expression;
    setState(() {
      _eligibility.add(criterion);
    });
  }

  void _removeEligibilityCriterion(index) {
    setState(() {
      _eligibility.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _eligibility = context.watch<DesignerState>().draftStudy.studyDetails.eligibility;
    _questions = context.watch<DesignerState>().draftStudy.studyDetails.questionnaire.questions;
    return _questions.isNotEmpty
        ? Stack(
            children: [
              Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                          child: Column(children: <Widget>[
                        ..._eligibility.asMap().entries.map((entry) => EligibilityCriterionEditor(
                            key: UniqueKey(),
                            eligibilityCriterion: entry.value,
                            questions: _questions,
                            remove: () => _removeEligibilityCriterion(entry.key)))
                      ])))),
              DesignerAddButton(label: Text('Add Criterion'), add: _addCriterion),
            ],
          )
        : Center(child: Text('No Questions added yet'));
  }
}