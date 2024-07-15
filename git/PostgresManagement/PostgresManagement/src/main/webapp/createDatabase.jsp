<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">

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

        .form-container h2 {
            margin-bottom: 20px;
        }
        .form-container label {
            display: block;
            margin-bottom: 5px;
        }
        .form-container input[type="text"],
        .form-container input[type="number"],
        .form-container input[type="submit"],
        .form-container input[type="password"],
        .form-container input[type="file"] {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .form-container input[type="submit"] {
            background-color: #3f51b5;
            color: white;
            border: none;
            cursor: pointer;
        }

    </style>
<title>Create database</title>
</head>
<body>
<%
	if(session.getAttribute("user name") == null)
	{
		response.sendRedirect("/index.jsp");
	}
%>
	 <div class="form-container">
        <h2>Create Database</h2>
        <form action="dbop" method="post">
            <label for="database-name">Enter the Database Name:</label>
            <input type="text" id="database name" name="database name">
            
            <label for="backup-interval">Enter the Backup interval in hours:</label>
            <input type="number" id="backup-interval" name="backup interval">
            
			<label for="schemas">Enter the no of Schemas required:</label>
            <input type="number" id="schemas" name="numschemas">
            
            <input type="submit" value="Submit">
        </form>
    </div>
</body>
</html>