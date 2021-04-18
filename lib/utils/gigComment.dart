import 'package:flutter/material.dart';
import 'apiTools.dart';

class GigComment extends StatefulWidget {
  final String? planComment;
  final planID;
  const GigComment({Key? key, required this.planComment, required this.planID})
      : super(key: key);

  @override
  GigCommentState createState() =>
      new GigCommentState(planComment: this.planComment, planID: this.planID);
}

class GigCommentState extends State<GigComment> with TickerProviderStateMixin {
  String? planComment;
  String? planID;

  GigCommentState({this.planComment, this.planID});

  //for user update on gig status
  TextEditingController? commentController;
  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    commentController!.dispose();
    super.dispose();
  }

  //for comment text field
  FocusNode nodeOne = FocusNode();
  bool visibilityComment = false;
  String commentButtonText = "Error";

  //hiding or showing comment text field depending on user comment entered for gig or not
  //need to pass this as required class var
  void _currentPlanComment() {
    if (planComment != "") {
      visibilityComment = true;
      commentButtonText = "Edit Comment";
    }
    if (planComment == "") {
      visibilityComment = false;
      commentButtonText = "Submit Comment";
    }
  }

  //declare var for check icon animation
  late Animation<double> _fabScale;
  late AnimationController animationController;

  void initState() {
    //build comment widget
    commentController = new TextEditingController(text: planComment);
    _currentPlanComment();

    //animation setup for check icon to confirm user comment input sent
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      }
    });
    _fabScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animationController, curve: Curves.bounceOut));
    _fabScale.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //if there is a comment, reveal the comment in textfield, if not, hide text field
        visibilityComment
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 15.0),
                      child: new TextField(
                        focusNode: nodeOne,
                        controller: commentController,
                        onSubmitted: (val) {
                          postComment(val, planID);
                          //fire the check icon
                          animationController.forward();
                        },
                      ),
                    ),
                  ),
                  //check icon to confirm the user input completed
                  Transform.scale(
                    scale: _fabScale.value,
                    child: Card(
                      shape: CircleBorder(),
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              )
            : new Container(),
        Container(
          alignment: Alignment.centerLeft,
          child: FlatButton(
            onPressed: () {
              //if a comment exists, clicking the button will focus on the textfield
              visibilityComment
                  ? FocusScope.of(context).requestFocus(nodeOne)
                  //if a comment doesn't exist, clicking the button will reveal text field and change
                  //the button text to editing
                  : setState(() {
                      visibilityComment = true;
                      commentButtonText = "Edit Comment";
                    });
            },
            child: Text(commentButtonText,
                style: TextStyle(
                    color: Color.fromRGBO(14, 39, 96, 1.0),
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }
}
