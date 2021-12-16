import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputStr = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            addGetConcreteEvent();
          },
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: MaterialButton(
                child: Text('Search'),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  context
                      .read<NumberTriviaBloc>()
                      .add(GetTriviaForConcreteNumberEvent(inputStr));
                  controller.clear();
                },
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: MaterialButton(
                onPressed: () {
                  controller.clear();
                  BlocProvider.of<NumberTriviaBloc>(context)
                      .add(GetTriviaForRandomNumberEvent());
                },
                child: Text('Get random trivia'),
              ),
            )
          ],
        )
      ],
    );
  }

  void addGetRandomEvent() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForRandomNumberEvent());
  }

  void addGetConcreteEvent() {
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForRandomNumberEvent());
    controller.clear();
  }
}
