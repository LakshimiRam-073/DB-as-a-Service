<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Postgres Management Software</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f0f4f7;
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 100vh;
    }
    .header {
        text-align: center;
        margin-bottom: 20px;
    }
    .button-container {
        display: flex;
        justify-content: center;
        flex-direction: row;
        align-items: center;
    }
    .button {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 200px;
        height: 100px;
        margin: 10px;
        font-size: 20px;
        text-align: center;
        border: 2px solid #000;
        border-radius: 10px;
        background-color: #3f51b5; /* Indigo */
        color: #fff;
        cursor: pointer;
        text-decoration: none;
        transition: background-color 0.3s ease, color 0.3s ease;
    }
    .button:hover {
        background-color: #303f9f; /* Darker Indigo */
        color: #e0e0e0;
    }
</style>
</head>
<body>
<%
    if(session.getAttribute("user name") == null) {
        response.sendRedirect("index.jsp");
    }
%>
<div class="header">
    <h1>Welcome, <% out.println((String)session.getAttribute("user name")); %>!</h1>
    <p>Select an option below to manage your Postgres users:</p>
</div>
<div class="button-container">
    <a href="clustUsers.jsp" class="button">Cluster Users</a>
    <a href="databaseUsers.jsp" class="button">Database Users</a>
</div>
</body>
</html>
