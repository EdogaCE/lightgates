import 'package:equatable/equatable.dart';
abstract class NavigationEvents extends Equatable{
  const NavigationEvents();
}

class ChangeDashboardNavBarItemEvent extends NavigationEvents{
  final int index;
  ChangeDashboardNavBarItemEvent(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];

}

class ChangeSelectedDateEvent extends NavigationEvents{
  final List events;
  ChangeSelectedDateEvent(this.events);
  @override
  // TODO: implement props
  List<Object> get props => [events];

}

class ChangeGalleryImageEvent extends NavigationEvents{
  final int index;
  ChangeGalleryImageEvent(this.index);
  @override
  // TODO: implement props
  List<Object> get props => [index];

}

class ChangeHomeViewPagerPositionEvent extends NavigationEvents{
  final int position;
  ChangeHomeViewPagerPositionEvent(this.position);
  @override
  // TODO: implement props
  List<Object> get props => [position];

}