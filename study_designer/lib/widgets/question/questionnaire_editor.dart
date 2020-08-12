import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_designer/widgets/question/question_editor.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/questionnaire.dart';

class QuestionnaireEditor extends StatefulWidget {
  final Questionnaire questionnaire;
  final List<String> questionTypes;

  const QuestionnaireEditor({@required this.questionnaire, @required this.questionTypes, Key key}) : super(key: key);

  @override
  _QuestionnaireEditorState createState() => _QuestionnaireEditorState();
}

class _QuestionnaireEditorState extends State<QuestionnaireEditor> {
  void _removeQuestion(index) {
    setState(() {
      widget.questionnaire.questions.removeAt(index);
    });
  }

  void _changeQuestionType(int index, String newType) {
    Question newQuestion;
    if (newType == BooleanQuestion.questionType) {
      newQuestion = BooleanQuestion();
    } else if (newType == ChoiceQuestion.questionType) {
      newQuestion = ChoiceQuestion()..choices = [];
    } else if (newType == AnnotatedScaleQuestion.questionType) {
      newQuestion = AnnotatedScaleQuestion();
    } else if (newType == VisualAnalogueQuestion.questionType) {
      newQuestion = VisualAnalogueQuestion()
        ..minimumColor = Colors.white
        ..minimumAnnotation = ''
        ..maximumColor = Colors.white
        ..maximumAnnotation = '';
    }
    newQuestion
      ..prompt = widget.questionnaire.questions[index].prompt
      ..rationale = widget.questionnaire.questions[index].rationale;
    setState(() {
      widget.questionnaire.questions[index] = newQuestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...widget.questionnaire.questions
            .asMap()
            .entries
            .map(
              (entry) => QuestionEditor(
                  key: UniqueKey(),
                  remove: () => _removeQuestion(entry.key),
                  changeQuestionType: (newType) => _changeQuestionType(entry.key, newType),
                  question: entry.value,
                  questionTypes: widget.questionTypes),
            )
            .toList(),
      ],
    );
  }
}
