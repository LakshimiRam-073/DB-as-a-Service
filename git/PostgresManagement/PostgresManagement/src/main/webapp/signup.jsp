<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.connect.DBconnector" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Sign Up</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f4;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
    }

    .form-container {
        width: 300px; 
        padding: 20px;
        border: 1px solid #ccc;
        border-radius: 5px;
        background-color: #fff;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }

    .form-container h2 {
        margin-bottom: 20px;
    }

    .form-container label {
        display: block;
        margin-bottom: 5px;
    }

    .form-container input[type="text"],
    .form-container input[type="password"],
    .form-container input[type="submit"] {
        width:280px;
        padding: 8px;
        margin-bottom: 10px;
        border: 1px solid #ccc;
        border-radius: 4px;
    }

    .form-container input[type="submit"] {
        background-color: #3f51b5;
        width:300px;
        margin-top:10px;
        color: white;
        border: none;
        cursor: pointer;
    }

    .error-message {
        color: red;
        margin-bottom: 10px;
    }

    .login-link {
        margin-top: 10px;
        text-align: center;
    }

    .login-link a {
        color: #3f51b5;
        text-decoration: none;
    }

    .login-link a:hover {
        text-decoration: underline;
    }
</style>
</head>
<body>
    <div class="form-container">
        <h2>Sign Up</h2>
        <form action="signup" method="post">
            <label for="username">User Name:</label>
            <input type="text" id="username" name="username">

            <label for="password">Password:</label>
            <input type="password" id="password" name="password">
            
            <label for="confirm-password">Confirm Password:</label>
            <input type="password" id="confirm-password" name="confirmPassword">

            <% Boolean showErrorMessage = (Boolean)request.getAttribute("showErrorMessage");
            if (showErrorMessage != null && showErrorMessage.booleanValue()) { 
           String error = "<div class=\"error-message\">Passwords do not match or user already exists.</div>";
           out.println(error);
             } 
            
            request.removeAttribute("showErrorMessage");
			%>
            <input type="submit" value="Sign Up">
        </form>
        
        <div class="login-link">
            <p>Already have an account? <a href="index.jsp">Login</a></p>
        </div>
    </div>
</body>
</html>
