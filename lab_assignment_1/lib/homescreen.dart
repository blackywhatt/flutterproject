//main page of the app where user inputs data and performs savings calculation.
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //controllers to handle user input for target, saving, and starting balance
  TextEditingController targetController = TextEditingController();
  TextEditingController savingController = TextEditingController();
  TextEditingController startController = TextEditingController();

  String frequency = 'Per Week'; //dropdown default value (per week or per month)
  String resultMessage = ''; //variable to store the result message to display in UI
  late double height, width; //variables to hold screen dimensions (for responsive layout)

  //function that calculates how many weeks are needed to reach the goal
  void calculateWeeks() {
    //convert text input into numbers, invalid input becomes 0
    double target = double.tryParse(targetController.text) ?? 0;
    double saving = double.tryParse(savingController.text) ?? 0;
    double starting = double.tryParse(startController.text) ?? 0;

    //input validation: ensure numbers are positive and not zero
    if (target <= 0 || saving <= 0) {
      setState(() {
        resultMessage = 'Please enter valid positive numbers.';
      });
      return;
    }

    //if starting balance is already enough, no need to calculate
    if (starting >= target) {
      setState(() {
        resultMessage = 'You have already reached your goal!';
      });
      return;
    }

    //convert monthly saving to weekly if selected
    double savingPerWeek = frequency == 'Per Month' ? saving / 4 : saving;

    //calculate total remaining and estimate total weeks
    double remaining = target - starting;
    int weeks = (remaining / savingPerWeek).round();

    setState(() { //update result message and refresh UI
      resultMessage =
          'You will reach your savings goal in approximately ${weeks.toStringAsFixed(1)} weeks.';
    });
  }

  @override
  Widget build(BuildContext context) {
    //get screen size for layout responsiveness
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    //limit maximum width to 400 for better readability on large screens
    if (width > 400) {
      width = 400;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goal Tracker')), // Top app bar title
      body: Center(
        child: SingleChildScrollView( //allows scrolling if content overflows
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Enter Your Savings Details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  //input field for target amount
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Amount (RM)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //input field for saving amount
                  TextField(
                    controller: savingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Saving Amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //input field for starting balance
                  TextField(
                    controller: startController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Starting Balance (RM)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //dropdown button for saving frequency
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Row(
                      children: [
                        const Text('Saving Frequency:'),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: frequency, //current selected value
                          items: const [
                            DropdownMenuItem(
                              value: 'Per Week',
                              child: Text('Per Week'),
                            ),
                            DropdownMenuItem(
                              value: 'Per Month',
                              child: Text('Per Month'),
                            ),
                          ],
                          //when user selects another value, update frequency
                          onChanged: (String? newValue) {
                            setState(() {
                              frequency = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  //button to do calculation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        calculateWeeks(); //run calculation function
                      },
                      child: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(height: 15),

                  //display result section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 186, 227), // soft pink background
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Result:',
                          style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        //display result text
                        Text(
                          resultMessage,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
