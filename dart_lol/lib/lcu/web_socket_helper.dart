library dart_lol;

class LCUWebSocketResponse {
  int status = 0;
  LCUWebSocketResponse(String response) {
    //print(response);
    if (response.contains("OnJsonApiEvent_lol-champ-select_v1_session")) {
      if (response.contains("Delete")) {
        status = 0;
      } else if (response.contains("Update")) {
        status = 1;
      }
    }
  }
}
