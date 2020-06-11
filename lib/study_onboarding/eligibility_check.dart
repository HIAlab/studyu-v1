import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';

import '../database/daos/study_dao.dart';
import '../database/models/models.dart';
import '../database/models/questionnaire/questionnaire_state.dart';
import '../database/models/questionnaire/questions/boolean_question.dart';
import '../database/models/questionnaire/questions/choice_question.dart';

class EligibilityCheckScreenArguments {
  final Study selectedStudy;

  EligibilityCheckScreenArguments(this.selectedStudy);
}

class EligibilityCheckScreen extends StatefulWidget {
  final Study study;

  EligibilityCheckScreen(this.study, {Key key}) : super(key: key);

  factory EligibilityCheckScreen.fromRouteArgs(EligibilityCheckScreenArguments args) =>
      EligibilityCheckScreen(args.selectedStudy);

  @override
  State<EligibilityCheckScreen> createState() => _EligibilityCheckScreenState();
}

class _EligibilityCheckScreenState extends State<EligibilityCheckScreen> {
  Study study;

  void resultCallback(BuildContext context, RPTaskResult result) {
    final formStepResult = result.getStepResultForIdentifier('onboardingFormStepID');
    var isEligible = false;
    String reason;
    if (formStepResult != null) {
      var qs = QuestionnaireState();
      formStepResult.results.forEach((key, value) {
        final stepResult = (value as RPStepResult);
        var question = study.studyDetails.questionnaire.questions.firstWhere((element) => element.id == key);

        switch (question.runtimeType) {
          case ChoiceQuestion:
            final cq = question as ChoiceQuestion;
            final response = stepResult.results['answer'] as List<RPChoice>;
            final ids = response.map((e) => e.value as int);
            final choices = ids.map((e) => cq.choices.elementAt(e));
            var constructAnswer = cq.constructAnswer(choices.toList());
            qs.answers[key] = constructAnswer;
            break;
          case BooleanQuestion:
            final bq = question as BooleanQuestion;
            final response = stepResult.results['answer'] as List<RPChoice>;
            var constructAnswer = bq.constructAnswer(response.first.value == 1);
            qs.answers[key] = constructAnswer;
            break;
        }
      });

      isEligible = study.studyDetails.eligibility.every((criterion) => criterion.isSatisfied(qs));
      if (!isEligible) {
        reason = study.studyDetails.eligibility.firstWhere((criterion) => criterion.isViolated(qs)).reason;
      }
    }
    if (!isEligible) {
      Navigator.pop(context, reason);
    } else {
      Navigator.pop(context, null);
    }

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: StudyDao().getStudyWithStudyDetails(widget.study),
      builder: (_context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Loading study'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ]),
          );
        }
        return RPUITask(
            task: createOnboarding(context, snapshot.data as Study),
            onSubmit: (result) => resultCallback(context, result),
        );
      },
    );
  }

  RPNavigableOrderedTask createOnboarding(BuildContext context, Study study) {
    final instructionStep = RPInstructionStep(
        identifier: 'instructionID',
        title: study.title,
        detailText: study.description,
        footnote: '(1) Important footnote')
      ..text = 'This survey decides, whether you are eligible for the ${study.title.toLowerCase()} study.';

    this.study = study;

    final questionSteps = study.studyDetails.questionnaire.questions
        .map((question) {
          switch (question.runtimeType) {
            case ChoiceQuestion:
              final choices = <RPChoice>[];
              (question as ChoiceQuestion).choices.asMap().forEach((key, value) {
                choices.add(RPChoice.withParams(value.text, key));
              });
              final answerFormat = RPChoiceAnswerFormat.withParams(
                  (question as ChoiceQuestion).multiple
                      ? ChoiceAnswerStyle.MultipleChoice
                      : ChoiceAnswerStyle.SingleChoice,
                  choices);
              return RPQuestionStep.withAnswerFormat(question.id, question.prompt, answerFormat);
            case BooleanQuestion:
              return RPQuestionStep.withAnswerFormat(question.id, question.prompt,
                  RPChoiceAnswerFormat.withParams(ChoiceAnswerStyle.SingleChoice, [
                    RPChoice.withParams('Yes', 1), RPChoice.withParams('No', 0)
                  ]));
            default:
              return null;
          }
        })
        .where((element) => element != null)
        .toList();

    final onboardingFormStep = RPFormStep.withTitle('onboardingFormStepID', questionSteps, 'Onboarding');

    final completionStep = RPCompletionStep('completionStepID')
      ..title = 'Thank You!'
      ..text = 'Continue for your results.';

    final steps = [instructionStep, completionStep];

    if (questionSteps.isNotEmpty) {
      steps.insert(1, onboardingFormStep);
    }

    final backPainSurveyTask = RPNavigableOrderedTask('backPainSurveyTaskID', steps, closeAfterFinished: false);

    return backPainSurveyTask;
  }
}