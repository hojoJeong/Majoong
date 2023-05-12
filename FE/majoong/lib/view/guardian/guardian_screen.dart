import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majoong/common/layout/loading_layout.dart';
import 'package:majoong/model/response/base_response.dart';
import 'package:majoong/model/response/map/location_point_response_dto.dart';
import 'package:majoong/viewmodel/share_loaction/share_location_provider.dart';

class GuardianScreen extends ConsumerStatefulWidget {
  const GuardianScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuardianState();
}

class _GuardianState extends ConsumerState<GuardianScreen> {
  @override
  Widget build(BuildContext context) {
    final shareLocationState = ref.watch(shareLocationProvider);

    if(shareLocationState is BaseResponse<bool>){
      ref.read(shareLocationProvider.notifier).receiveLocation();
    }
    if(shareLocationState is BaseResponse<LocationPointResponseDto>){
      return Scaffold(
        body: Center(child: Text('${shareLocationState.data!.lat}, ${shareLocationState.data!.lng}'),),
      );
    }
    else {
      return LoadingLayout();
    }

  }

}
