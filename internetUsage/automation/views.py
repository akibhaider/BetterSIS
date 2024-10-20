from rest_framework.decorators import api_view # type: ignore
from rest_framework.response import Response # type: ignore
from .selenium_logic import login_and_get_usage

@api_view(['POST'])
def get_usage(request):
    print("Views module imported successfully.")

    username = request.data.get('username')
    password = request.data.get('password')
    
    if not username or not password:
        return Response({"error": "Missing username or password"}, status=400)
    
    try:
        table_data = login_and_get_usage(username, password)
        return Response({"usage": table_data,})
    except Exception as e:
        return Response({"error": str(e)}, status=500)