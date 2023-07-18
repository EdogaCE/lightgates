import 'package:school_pal/blocs/navigatoins/navigation_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_events.dart';

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates>{
  NavigationBloc() : super(InitialState());

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async*{
    // TODO: implement mapEventToState
    if(event is ChangeDashboardNavBarItemEvent){
      yield DashboardNavBarItemChanged(event.index);
    }else if(event is ChangeSelectedDateEvent){
      yield SelectedDateChanged(event.events);
    }else  if(event is ChangeGalleryImageEvent){
      yield GalleryImageChanged(event.index);
    }else if(event is ChangeHomeViewPagerPositionEvent){
      yield HomeViewPagerPositionChanged(event.position);
    }
  }

}