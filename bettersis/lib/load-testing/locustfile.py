import firebase_admin
from firebase_admin import credentials, firestore, initialize_app
from locust import HttpUser, task, between

cred = credentials.Certificate("./bettersis-e573c-firebase-adminsdk-13a1r-a93dcdfcfb.json")

firebase_admin.initialize_app(cred)

db = firestore.client() 

class FirebaseUser(HttpUser):
    wait_time = between(1, 3) 

    @task(2)
    def read_firestore(self):
        """Simulate reading attendance data for a course"""
        try:
            course_id = "CSE-4513"  
            section = random.choice(["1", "2"])  
            date = "21-11-2024" 

            # Firestore path for attendance
            doc_ref = db.collection("Attendance").document(course_id).collection("Sections").document(section).collection("Attendance").document(date)
            doc = doc_ref.get()

            if doc.exists:
                print(f"Read attendance for {course_id}, Section {section}")
            else:
                print("No data found.")
        except Exception as e:
            print(f"Error reading Firestore: {e}")