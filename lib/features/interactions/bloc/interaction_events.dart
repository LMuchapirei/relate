
import 'package:flutter/material.dart';

abstract class InteractionEvent {
  const InteractionEvent();
}


class TitleEvent extends InteractionEvent {
  final String title;
  const TitleEvent(this.title);
}

class NotesEvent extends InteractionEvent {
  final String note;
  const NotesEvent(this.note);
}

class FrequencyEvent extends InteractionEvent {
  final String frequency;
  const FrequencyEvent(this.frequency);
}

class PriorityEvent extends InteractionEvent {
  final String priority;
  const PriorityEvent(this.priority);
}

class SelectedDateEvent extends InteractionEvent {
  final DateTime date;
  const SelectedDateEvent(this.date);
}

class SelectedTimeEvent extends InteractionEvent {
  final TimeOfDay time;
  const SelectedTimeEvent(this.time);
}

class SelectedRedirectAppEvent extends InteractionEvent {
  final String appSelected;
  const SelectedRedirectAppEvent(this.appSelected);
}

class LoadScheduledInteractions extends InteractionEvent {
  
}