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
    
    
<title>Create Cluster</title>
</head>
<body>
<%
	if(session.getAttribute("user name") == null)
	{
		response.sendRedirect("/index.jsp");
	}
%>
	 <div class="form-container">
        <h2>Create Cluster</h2>
        <form action="createclust" method="post">
            <label for="cluster-name">Enter the Cluster Name:</label>
            <input type="text" id="cluster-name" name="clust name">

			<label for="version">Enter the Version for Cluster:</label>
            <input type="text" id="version" name="version">
            
            <label for="backup-interval">Enter the Backup interval in hours:</label>
            <input type="number" id="backup-interval" name="backup interval">
            
            <label for="replication-count">Enter the Replication Count(Cascading):</label>
            <input type="number" id="replication-count" name="replication count">
			
            
            <input type="submit" value="Submit">
        </form>
    </div>
</body>
</html>