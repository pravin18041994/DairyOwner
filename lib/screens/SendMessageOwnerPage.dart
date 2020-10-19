import 'package:flutter/material.dart';

class SendMessageOwnerPage extends StatefulWidget {
  @override
  _SendMessageOwnerPageState createState() => _SendMessageOwnerPageState();
}

class _SendMessageOwnerPageState extends State<SendMessageOwnerPage> {
  TextEditingController messageController = TextEditingController();

  final FocusNode sendButton = FocusNode();

  bool isSelected = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  selectUserdialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.18,
                      child: RaisedButton(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          child: Text(
                            "Ok",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {})),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.18,
                      child: RaisedButton(
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          })),
                ],
              ),
            )
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.black)),
          title: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                    separatorBuilder: (ctx, index) => Divider(),
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder: (ctx, index) => Column(
                          children: [
                            Container(
                              height: 20,
                              child: Row(
                                children: [
                                  Checkbox(value: true, onChanged: (value) {}),
                                  Text(
                                    "Area name1",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: 4,
                                itemBuilder: (ctx, index) => Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Container(
                                    height: 30,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            value: true, onChanged: (value) {}),
                                        Text(
                                          "User 1",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Message",style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                          hintText: "Write your message here!",
                          hintStyle: TextStyle(
                            color: Colors.black,
                          ),
                          focusColor: Colors.blue,
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black))),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Radio(
                                  value: 1,
                                  groupValue: null,
                                  onChanged: (val) {}),
                              Text("Send all"),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Radio(
                                  value: 1,
                                  groupValue: null,
                                  onChanged: (val) {
                                    selectUserdialog();
                                  }),
                              Text("Send few"),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: RaisedButton(
                    focusNode: sendButton,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    color: Colors.blue,
                    child: Text(
                      "Send",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {}),
              )
            ],
          ),
        ),
      ),
    );
  }
}
