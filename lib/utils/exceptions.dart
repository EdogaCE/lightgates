class NetworkError extends Error{}

class SystemError extends Error{}

class ApiException implements Exception{
  final String message;
  ApiException(this.message);
  String toString(){
    return message;
  }
}