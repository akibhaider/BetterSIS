from django.urls import path
from . import views

urlpatterns = [
    path('get-usage/', views.get_usage, name='get_usage'),
]
