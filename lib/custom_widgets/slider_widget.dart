import 'package:flutter/material.dart';

import '../deck_data.dart';

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final int min;
  final int max;
  final fullWidth;
  final fullHeight;
  final Flashcard card;
  Function(double)? onSliderChanged = (value){};

  SliderWidget(
      {super.key, this.sliderHeight = 50,
        this.max = 10,
        this.min = 0,
        this.fullWidth = true,
        this.fullHeight = false,
        required this.card, required Function(double value) this.onSliderChanged});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();

  String formattedTime(Duration t){
    if(t.inMinutes<120){
      return "${t.inMinutes} minutes";
    }else if(t.inHours<24){
      return "${t.inHours} hour${(t.inHours>1)?"s":""}";
    }else if(t.inDays<7){
      return "${t.inDays} day${(t.inDays>1)?"s":""}";
    }else if(t.inDays<365){
      return "${t.inDays~/7} week${((t.inDays~/7)>1)?"s":""}";
    }else{
      return "${t.inDays~/365} year${((t.inDays~/365)>1)?"s":""}";
    }
  }

}

class _SliderWidgetState extends State<SliderWidget> {
  double _slideFactor = 0;

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return Column(
      children: [
        Stack(
          children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: widget.fullHeight?double.infinity:(this.widget.sliderHeight),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular((this.widget.sliderHeight * 0.3)),
                      bottomLeft: Radius.circular((this.widget.sliderHeight * 0.3))
                    ),
                    gradient: const LinearGradient(
                        colors: [
                          Color(0xFFc62828),
                          Color(0xffff8311),
                          //Color(0xFFff7961),
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 1.00),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: widget.fullHeight?double.infinity:(this.widget.sliderHeight),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular((this.widget.sliderHeight * 0.3)),
                      bottomRight: Radius.circular((this.widget.sliderHeight * 0.3))
                    ),
                    gradient: const LinearGradient(
                        colors: [
                          Color(0xFF80e27e),
                          Color(0xFF2e7d32),
                        ],
                        begin: Alignment.centerLeft,//FractionalOffset(0.0, 0.0),
                        end: Alignment.centerRight,//FractionalOffset(1.0, 1.00),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                ),
              ),
            ],
          ),
            Padding(
              padding: EdgeInsets.fromLTRB(this.widget.sliderHeight * paddingFactor,
                  2, this.widget.sliderHeight * paddingFactor, 2),
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),
                    trackHeight: 4.0,
                    overlayColor: Colors.white.withOpacity(.4),
                    //valueIndicatorColor: Colors.white,
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.red.withOpacity(.7),
                  ),
                  child:
                    Slider(
                      min: 0,
                      max: 6,
                      value: _slideFactor,
                      divisions: 5,
                      label: "Next repetition: ${widget.formattedTime(widget.card.reviewInterval(_slideFactor, widget.card.repetitions))}",
                      onChanged: (double value) {
                        setState(() {
                          _slideFactor = value;
                          widget.onSliderChanged!(value);
                        });
                      },
                ),
              ),
              )
            ),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
          child: Row(
            children: <Widget>[
              const Text(
                'Very difficult',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,

                ),
              ),
              Expanded(child: Container()),
              const Text(
                'Very easy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ]
    );
  }
}