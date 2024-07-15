<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Login</title>
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

        .login-container {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 300px;
            text-align: center;
        }

     .login-container h2{
     	text-align:left;
     	padding-top:10px;
     }

        .form-container label {
            display: block;
            margin-bottom: 5px;
            text-align: left;
        }

        .form-container input[type="text"],
        .form-container input[type="password"] {
            width: calc(100% - 16px);
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        .form-container input[type="submit"] {
            width: 100%;
            background-color: #3f51b5;
            color: white;
            border: none;
            cursor: pointer;
            padding: 10px;
            border-radius: 4px;
        }

        .error-message {
            color: red;
            margin-bottom: 10px;
        }

        .signup-link {
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Login</h2>
        <form action="login" method="post" class="form-container">
            <label for="username">User Name:</label>
            <input type="text" id="username" name="user name">

            <label for="password">Password:</label>
            <input type="password" id="password" name="password">

            <%
                Boolean isWrongVal = (Boolean) session.getAttribute("showmessage");
                if (isWrongVal != null && isWrongVal.booleanValue()) {
                    String error = "<div class=\"error-message\">Wrong User name or password</div>";
                    out.println(error);
                }
                session.removeAttribute("showmessage");
            %>
            <input type="submit" value="Submit">
        </form>
        <p class="signup-link">Don't have an account, <a href="signup.jsp">go to signup</a>.</p>
    </div>
</body>
</html>
