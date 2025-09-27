

import '../base_response_model.dart';
import '../driver_documents_model.dart';

class DriverDocumentsResponse extends BaseResponseModel{
  final DriverDocumentsModel? driverDocumentsModel;

  DriverDocumentsResponse({
    super.isSuccess,
    super.message,
    this.driverDocumentsModel,
  });

   static DriverDocumentsResponse fromJson(Map<String, dynamic> json) {
    return DriverDocumentsResponse(
      isSuccess: json['isSuccess'],
      message: json['message'],
      driverDocumentsModel: json['driver_documents'],
 );
  }
}
