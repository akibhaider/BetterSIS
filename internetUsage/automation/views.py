from rest_framework.decorators import api_view
from rest_framework.response import Response
from .selenium_logic import login_and_get_usage

@api_view(['POST'])
def get_usage(request):
    print("Views module imported successfully.")

    username = request.data.get('username')
    password = request.data.get('password')

    # username = "fahimrahman"
    # password = "248"
    
    if not username or not password:
        return Response({"error": "Missing username or password"}, status=400)
    
    try:
        usage = login_and_get_usage(username, password)
        print(usage)
        return Response({"usage": usage})
    except Exception as e:
        return Response({"error": str(e)}, status=500)