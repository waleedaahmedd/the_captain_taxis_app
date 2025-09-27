
import '../base_response_model.dart';
import '../driver_shift_model.dart';

class DriverShiftResponse extends BaseResponseModel{
  final DriverShiftModel? driverShiftModel;

  DriverShiftResponse({
    super.isSuccess,
    super.message,
    this.driverShiftModel,
  });

   static DriverShiftResponse fromJson(Map<String, dynamic> json) {
    return DriverShiftResponse(
      isSuccess: json['isSuccess'],
      message: json['message'],
      driverShiftModel: json['data'],
 );
  }
}
