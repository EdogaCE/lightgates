import 'package:equatable/equatable.dart';
abstract class NavigationStates extends Equatable{
  const NavigationStates();
}

class InitialState extends NavigationStates{
  const InitialState();
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class DashboardNavBarItemChanged extends NavigationStates {
  final int index;
  DashboardNavBarItemChanged(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];
}

class SelectedDateChanged extends NavigationStates {
  final List events;
  SelectedDateChanged(this.events);
  @override
  // TODO: implement props
  List<Object> get props => [events];
}

class GalleryImageChanged extends NavigationStates {
  final int index;
  GalleryImageChanged(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];
}

class HomeViewPagerPositionChanged extends NavigationStates {
  final int position;
  HomeViewPagerPositionChanged(this.position);
  @override
  // TODO: implement props
  List<Object> get props => [position];
}