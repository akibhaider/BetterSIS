# BetterSIS

![Contributors](https://img.shields.io/github/contributors/akibhaider/BetterSIS?color=darkgreen) ![Forks](https://img.shields.io/github/forks/akibhaider/BetterSIS?style=social) ![Stargazers](https://img.shields.io/github/stars/akibhaider/BetterSIS?style=social) ![Issues](https://img.shields.io/github/issues/akibhaider/BetterSIS?color=brown)

## Introduction
BetterSIS is a Student Information System designed specifically for Islamic University of Technoogy(IUT) to simplify student data management and streamline academic processes. Below are necessary instructions provided to run all the source codes (for developers) and to deply and run the appication (for users).

## Features and Services
Extensively, there are three targetted user base for this applications. (Features are explained in separate sections)

1.0 ***Student***
- **Academic Result**:  
i) Detail marks of all enrolled courses of all academic semesters
ii) Semester wise CGPA graph and evaluation report 
iii) AI generated personalized feedback for further improvement(based on exam performance data, regularity of class attendance and some other parameters)  
- **Smart Student Wallet**: 
i) Smart Card recharge system from within the app using online payment systems (Bkash online payment).
ii) All transaction histories and balance used in various services(Transportation, Meal Token, Printing etc
iii) Integrating AB Direct for transactions between bank to system (Developement in progress, future release)
- **Academics**: 
i) Register into courses and see details of enrolled courses for each semester
ii) Admit card and class routine view and download automatically from dashboard
iii) See important announcements of academic activities
iv) Get notified of upcoming exams and seat plan 
v) Google Classroom codes and online class information from course teacher
vi) Course Feedback and Teacher Evaluation report (Developement in progress, future release) 
- **Meal Token**: 
i) Buy Cafeteria Meal token using Smart Wallet or other Digital payment method (Bkash)
ii) Buy and Transfer token to other users of the system (students, teachers or stuffs)
iii) Smart refund policy of buying token (Based on the expected number of meals planned for students)
- **Library**:
i) Question Bank of all previous academic years (sorted department, program and semester wise)
ii) Course Materials and necessary lecture notes shared by others
iii) Course Outlines and Outcomes
iv) Access books from Library
v) Contribute materials in library to help others and grow the community
- **Transportation**:
i) Bus ticket purchasing with detailed schedules and plan ahead!
- **Internet Usage**:
i) Location wise internet usage history (integrated third party application and helper program like netman)
ii) Connected Device details (TCP/IP layer protocol addresses) and Connection Timing details (daily start and end times) 
iii) Alert System for when the Internet Limit is exceeded
- **Class Attendance**:
i) Notify students, take course attendance and keeps track of previous attendance history
- **Complain and Feedback**:
i) Submit complain to any issues and propose any improvements to the authority

1.1 ***Class Representatives***
Additional features of CRs are:
i) Create Announcements for other students
ii) Upload necessary course materials

2 ***Teachers***


3 ***Admins***



****Exciting Features****
- **IUT Email Verification**: Access to IUT SIS 2.0 will be exclusively available to IUT students. Account creation and system login will be restricted to those using an official IUT email address.
- **Revamped Dashboard Experience**: IUT SIS 2.0 will feature a redesigned dashboard with an intuitive interface, providing a clear and organized view of all student details.
- **Department Themed Interface**: The app will feature a customized theme for each department, reflecting their official colors. For example, CSE students will have a blue-themed interface.
- **Resources with Restricted Access**: Study materials, including book PDFs, lecture slides, and recordings, will be stored in a secure database. Access to these resources will be granted only to authorized students, ensuring controlled and limited availability.
- **Tution Fees Status**: Students will receive updates on their tuition fee status (paid or outstanding), with the amount shown in both USD and BDT, based on the current exchange rate.

## Expected Customers

- **IUT TEACHERS**
- **IUT STUDENTS**
- **IUT STAFF**

## Technology Specifications

- **STANDARD SOFTWARE**:
  1. FLUTTER for development
  2. FIREBASE for database system
  3. ANDROID STUDIO | 2024.1.2
- **NON STANDARD HARDWARES**:
  1. IUT SMART CARD
  2. QR CODE/NFC READER
- **NON STANDARD SOFTWARES**: ONLINE PAYMENT GATEWAY

## System Interaction

<table align="center">
  <tr>
    <td align="center">
      <img src="ui/Home.png" alt="Home Page" width="150"/><br/>
      <em>Home Page</em>
    </td>
    <td align="center">
      <img src="ui/Dashboard.png" alt="Feature Dashboard" width="150"/><br/>
      <em>Feature Dashboard</em>
    </td>
    <td align="center">
      <img src="ui/Academics.png" alt="Academic Updates and Schedules" width="150"/><br/>
      <em>Academic Updates and Schedules</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="ui/Internet.png" alt="Internet Usage Tracker" width="150"/><br/>
      <em>Internet Usage Tracker</em>
    </td>
    <td align="center">
      <img src="ui/Library.png" alt="E-Library and Question Bank" width="150"/><br/>
      <em>E-Library and Question Bank</em>
    </td>
    <td align="center">
      <img src="ui/Result.png" alt="Semester wise Course Results" width="150"/><br/>
      <em>Semester wise Course Results</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="ui/AddMoney.png" alt="E-Banking with AB-Direct" width="150"/><br/>
      <em>E-Banking with AB-Direct</em>
    </td>
    <td align="center">
      <img src="ui/SmartWallet.png" alt="Smart Wallet" width="150"/><br/>
      <em>Smart Wallet</em>
    </td>
    <td align="center">
      <img src="ui/Transportation.png" alt="Iut Bus Service Tracker" width="150"/><br/>
      <em>Iut Bus Service Tracker</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="ui/MealToken.png" alt="Meal Token with QR Code" width="150"/><br/>
      <em>Meal Token with QR Code</em>
    </td>
  </tr>
</table>

## Sprint Backlog

- Here you can find the sprint backlog for this project: https://docs.google.com/spreadsheets/d/1RDhU2heGX9ymsFlywrJ08rLO7RbqRG4N989avHTFXds/edit?usp=sharing

### Installation and Setup

## Clone the Repository:
```bash
git clone https://github.com/akibhaider/BetterSIS.git
cd BetterSIS

