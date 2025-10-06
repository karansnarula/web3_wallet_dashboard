import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/request/get_tokens_request.dart';
import '../../models/response/get_tokens_response.dart';

part 'token_api.g.dart';

@RestApi()
abstract class TokenApi {
  factory TokenApi(Dio dio, {String baseUrl}) = _TokenApi;

  @POST('assets/tokens/by-address')
  Future<GetTokensResponse> getTokensByAddress(
      @Body() GetTokensRequest request,
      );
}
