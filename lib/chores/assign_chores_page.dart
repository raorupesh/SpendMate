import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/chores/chores_details_page.dart';
import 'package:spendmate/providers/chores_provider.dart';

class AssignChoresPage extends StatefulWidget {
  const AssignChoresPage({super.key});

  @override
  _AssignChoresPageState createState() => _AssignChoresPageState();
}

class _AssignChoresPageState extends State<AssignChoresPage> {
  final TextEditingController _choreNameController = TextEditingController();
  final TextEditingController _participantNameController = TextEditingController();

  String _selectedAssignmentType = "Manual Task";

  final List<String> participants = [];
  final List<String> daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final List<String> tasks = ["Cleaning", "Dishes", "Cooking", "Laundry", "Trash", "Other"];

  Map<String, Map<String, String>> directAssignments = {};
  Map<String, Map<String, String>> availableHours = {};
  Map<String, Map<String, String>> busyHours = {};
  Map<String, bool> expandedState = {}; // Track expanded state for each participant

  // This map will hold the final calculated assignments
  Map<String, Map<String, String>> finalAssignments = {};

  @override
  void dispose() {
    _choreNameController.dispose();
    _participantNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Weekly Chores"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _choreNameController,
              decoration: const InputDecoration(
                labelText: "Chore Plan Name",
                hintText: "Enter a name for this chore plan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Assignment Type Dropdown
            Row(
              children: [
                const Text("Assignment Type: ", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedAssignmentType,
                  items: ["Manual Task", "Available Time", "Busy Time"].map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAssignmentType = value!;
                    });
                  },
                ),
              ],
            ),

            // Description based on selected type
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _getAssignmentTypeDescription(),
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ),

            const SizedBox(height: 16),

            // Add Participant Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _participantNameController,
                    decoration: const InputDecoration(
                      hintText: "Enter participant name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Add"),
                  onPressed: () {
                    _addParticipant();
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Participant count display
            Text(
              "${participants.length} participants added",
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),

            const SizedBox(height: 16),

            // Dynamic Participant Tiles
            participants.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Add participants to begin assigning chores",
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ),
            )
                : Column(
              children: participants.map((person) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(person, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _removeParticipant(person);
                              },
                            ),
                            Icon(expandedState[person]! ? Icons.expand_less : Icons.expand_more),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            expandedState[person] = !expandedState[person]!;
                          });
                        },
                      ),
                      if (expandedState[person]!) _buildTaskFields(person),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Save Button
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                icon: const Icon(Icons.save),
                label: const Text("Save Chore Plan"),
                onPressed: participants.isEmpty || _choreNameController.text.trim().isEmpty
                    ? null // Disable button if no participants or no chore name
                    : () {
                  _saveAndNavigate(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAssignmentTypeDescription() {
    switch (_selectedAssignmentType) {
      case "Manual Task":
        return "Manually assign specific tasks to each person for each day of the week.";
      case "Available Time":
        return "Specify when each person is available, and tasks will be automatically assigned during available hours.";
      case "Busy Time":
        return "Specify when each person is busy, and tasks will be automatically assigned during non-busy hours.";
      default:
        return "";
    }
  }

  void _addParticipant() {
    if (_participantNameController.text.trim().isNotEmpty) {
      final newParticipant = _participantNameController.text.trim();

      // Check for duplicates
      if (participants.contains(newParticipant)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$newParticipant is already added")),
        );
        return;
      }

      setState(() {
        participants.add(newParticipant);
        directAssignments[newParticipant] = {};
        availableHours[newParticipant] = {};
        busyHours[newParticipant] = {};
        expandedState[newParticipant] = true; // Auto-expand when added
        _participantNameController.clear();
      });
    }
  }

  void _removeParticipant(String person) {
    setState(() {
      participants.remove(person);
      directAssignments.remove(person);
      availableHours.remove(person);
      busyHours.remove(person);
      expandedState.remove(person);
    });
  }

  // Generate assignments based on available time
  void _generateAssignmentsFromAvailability() {
    finalAssignments = {};

    // Initialize assignments map for each participant
    for (String person in participants) {
      finalAssignments[person] = {};
    }

    // For each day of the week
    for (String day in daysOfWeek) {
      // Map to track which tasks have been assigned for this day
      Map<String, bool> assignedTasks = {};
      for (String task in tasks) {
        assignedTasks[task] = false;
      }

      // Track which people already have assignments for this day
      List<String> assignedPeople = [];

      // First pass: process people with specific availability
      List<String> availablePeople = [];

      for (String person in participants) {
        // Check if person has valid availability data for this day
        bool hasAvailability = availableHours[person] != null &&
            availableHours[person]![day] != null &&
            availableHours[person]![day]!.isNotEmpty &&
            availableHours[person]![day]!.contains(" - ");

        if (hasAvailability) {
          availablePeople.add(person);
        }
      }

      // Sort available people by amount of availability (if we had parsed time values)
      // For now, just use them in the order they appear

      // Assign tasks to available people
      for (String person in availablePeople) {
        for (String task in tasks) {
          if (!assignedTasks[task]!) {
            finalAssignments[person]![day] = task;
            assignedTasks[task] = true;
            assignedPeople.add(person);
            break; // Assign only one task per person per day
          }
        }

        // If all tasks are assigned, no need to continue
        if (!assignedTasks.containsValue(false)) break;
      }

      // Second pass: assign remaining tasks to people who didn't specify availability
      for (String person in participants) {
        // Skip people who already have assignments
        if (assignedPeople.contains(person)) continue;

        for (String task in tasks) {
          if (!assignedTasks[task]!) {
            finalAssignments[person]![day] = task;
            assignedTasks[task] = true;
            break; // Assign only one task per person per day
          }
        }

        // If all tasks are assigned, no need to continue
        if (!assignedTasks.containsValue(false)) break;
      }
    }
  }

  // Generate assignments based on busy time (inverse of available time)
  void _generateAssignmentsFromBusyTime() {
    finalAssignments = {};

    // Initialize assignments map for each participant
    for (String person in participants) {
      finalAssignments[person] = {};
    }

    // For each day of the week
    for (String day in daysOfWeek) {
      // Map to track which tasks have been assigned for this day
      Map<String, bool> assignedTasks = {};
      for (String task in tasks) {
        assignedTasks[task] = false;
      }

      // List to track which people already have assignments
      List<String> assignedPeople = [];

      // First, prioritize people who are NOT busy
      List<String> nonBusyPeople = [];
      List<String> busyPeople = [];

      for (String person in participants) {
        bool isBusy = busyHours[person] != null &&
            busyHours[person]![day] != null &&
            busyHours[person]![day]!.isNotEmpty &&
            busyHours[person]![day]!.contains(" - ");

        if (isBusy) {
          busyPeople.add(person);
        } else {
          nonBusyPeople.add(person);
        }
      }

      // First assign tasks to non-busy people
      for (String person in nonBusyPeople) {
        for (String task in tasks) {
          if (!assignedTasks[task]!) {
            finalAssignments[person]![day] = task;
            assignedTasks[task] = true;
            assignedPeople.add(person);
            break; // Assign only one task per person per day
          }
        }

        // If all tasks are assigned, no need to continue
        if (!assignedTasks.containsValue(false)) break;
      }

      // Then assign remaining tasks to busy people (they have to do them despite being busy)
      for (String person in busyPeople) {
        if (assignedPeople.contains(person)) continue;

        for (String task in tasks) {
          if (!assignedTasks[task]!) {
            finalAssignments[person]![day] = task;
            assignedTasks[task] = true;
            break; // Assign only one task per person per day
          }
        }

        // If all tasks are assigned, no need to continue
        if (!assignedTasks.containsValue(false)) break;
      }
    }
  }

  void _saveAndNavigate(BuildContext context) {
    if (_choreNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name for the chore plan")),
      );
      return;
    }

    if (participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one participant")),
      );
      return;
    }

    // Generate the allocations based on assignment type
    if (_selectedAssignmentType == "Available Time") {
      _generateAssignmentsFromAvailability();
    } else if (_selectedAssignmentType == "Busy Time") {
      _generateAssignmentsFromBusyTime();
    } else {
      // For manual tasks, we use the directly assigned tasks
      finalAssignments = Map.from(directAssignments);
    }

    // Check if any assignments were made
    bool hasAssignments = false;
    for (var personAssignments in finalAssignments.values) {
      if (personAssignments.isNotEmpty) {
        hasAssignments = true;
        break;
      }
    }

    if (!hasAssignments) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No chores were assigned. Please check your settings.")),
      );
      return;
    }

    // Save to the provider
    final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
    final newChorePlan = ChorePlan(
      choreName: _choreNameController.text.trim(),
      participants: List.from(participants),
      directAssignments: finalAssignments, // Use the calculated assignments
      finalSchedule: {
        // Include both available and busy time info for reference
        "availableHours": availableHours,
        "busyHours": busyHours,
      },
    );

    choreProvider.addChorePlan(newChorePlan);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Chore Plan Saved Successfully!"),
        backgroundColor: Colors.grey,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChoresDetailsPage()),
    );
  }

  Widget _buildTaskFields(String person) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedAssignmentType == "Manual Task") _buildManualTaskFields(person),
          if (_selectedAssignmentType == "Available Time") _buildAvailableTimeFields(person),
          if (_selectedAssignmentType == "Busy Time") _buildBusyTimeFields(person),
        ],
      ),
    );
  }

  Widget _buildAvailableTimeFields(String person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text("When is this person available?", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...daysOfWeek.map((day) {
          // Ensure the map has default values
          availableHours[person] ??= {};

          // Extract existing times if present
          String startTime = '';
          String endTime = '';

          if (availableHours[person]![day] != null && availableHours[person]![day]!.contains(' - ')) {
            List<String> parts = availableHours[person]![day]!.split(' - ');
            startTime = parts[0];
            endTime = parts.length > 1 ? parts[1] : '';
          }

          return Card(
            elevation: 0,
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Start Time",
                            hintText: "e.g. 9:00 AM",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          initialValue: startTime,
                          onChanged: (value) {
                            setState(() {
                              availableHours[person]![day] = "${value} - ${endTime}";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "End Time",
                            hintText: "e.g. 5:00 PM",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          initialValue: endTime,
                          onChanged: (value) {
                            setState(() {
                              availableHours[person]![day] = "${startTime} - $value";
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBusyTimeFields(String person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text("When is this person busy?", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...daysOfWeek.map((day) {
          // Ensure the map has default values
          busyHours[person] ??= {};

          // Extract existing times if present
          String startTime = '';
          String endTime = '';

          if (busyHours[person]![day] != null && busyHours[person]![day]!.contains(' - ')) {
            List<String> parts = busyHours[person]![day]!.split(' - ');
            startTime = parts[0];
            endTime = parts.length > 1 ? parts[1] : '';
          }

          return Card(
            elevation: 0,
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Start Time",
                            hintText: "e.g. 9:00 AM",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          initialValue: startTime,
                          onChanged: (value) {
                            setState(() {
                              busyHours[person]![day] = "${value} - ${endTime}";
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "End Time",
                            hintText: "e.g. 5:00 PM",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          initialValue: endTime,
                          onChanged: (value) {
                            setState(() {
                              busyHours[person]![day] = "${startTime} - $value";
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildManualTaskFields(String person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text("Assign tasks for each day:", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...daysOfWeek.map((day) {
          return Card(
            elevation: 0,
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
                  DropdownButton<String>(
                    hint: const Text("Assign Task"),
                    value: directAssignments[person]?[day], // Retrieve assigned task
                    underline: Container(height: 1, color: Colors.tealAccent),
                    items: tasks.map((task) {
                      return DropdownMenuItem(value: task, child: Text(task));
                    }).toList(),
                    onChanged: (task) {
                      setState(() {
                        if (task != null) {
                          directAssignments[person] ??= {}; // Initialize if null
                          directAssignments[person]![day] = task;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}