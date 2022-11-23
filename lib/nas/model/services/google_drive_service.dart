import 'package:flutter_customer_app/nas/model/services/base_service.dart';

class DriveService extends BaseService {
  static Future getAccessTokenUsingRefreshToken() async
  {
    String clientId = "1056141531173-1kjv36m3lch0n2971g2nej3lo9bolr9m.apps.googleusercontent.com";
    String clientSecret = "POtFL6tGi6VIxZq-Tz5_w3-C";
    String grantType = "refresh_token";
    String refreshToken = "1/nor-jq1WasZuzsP0UaLW0vv0ucE4NwGfAvkgfAg-dwNdRFhL9eUzNBN14-gnpHRd";

    String url = "https://www.googleapis.com/oauth2/v4/token?client_id=$clientId&client_secret=$clientSecret&grant_type=$grantType&refresh_token=$refreshToken";
    return await BaseService().getDriveUtilsResponse(url, requestType: 'POST', refreshRequired: true);
  }

  static Future getDocument(String documentId) async {
    return await BaseService().getDriveUtilsResponse("https://docs.googleapis.com/v1/documents/" + documentId);
  }

  static Future getDocumentAsPdf(String documentId) async {
    return await BaseService().getDriveUtilsResponse("https://www.googleapis.com/drive/v3/files/" + documentId + "/export?mimeType=application/pdf", responseFormat: 'bytes');
  }
}
