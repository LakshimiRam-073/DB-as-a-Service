<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.connect.DBconnector" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Database Services</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f0f4f8;
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
    }
    .container {
        display: flex;
        width: 80%;
        max-width: 1200px;
    }
    .button-container {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        margin-right: 20px;
    }
    .button {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 220px;
        height: 50px;
        margin: 10px 0;
        font-size: 18px;
        text-align: center;
        border: 2px solid #303f9f;
        border-radius: 10px;
        background-color: #3f51b5;
        color: #fff;
        text-decoration: none;
        transition: background-color 0.3s, border-color 0.3s;
    }
    .button:hover {
        background-color: #303f9f;
        border-color: #1a237e;
    }
    .button img {
        width: 30px;
        height: 30px;
        margin-right: 10px;
    }
    .installed-databases {
        flex-grow: 1;
        background-color: #ffffff;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }
    .installed-databases h2 {
        margin-top: 0;
    }
    table {
        width: 100%;
        border-collapse: collapse;
    }
    table, th, td {
        border: 1px solid #ddd;
    }
    th, td {
        padding: 8px;
        text-align: left;
    }
    th {
        background-color: #3f51b5;
        color: white;
    }
    .remove-button {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100px;
        height: 30px;
        font-size: 14px;
        text-align: center;
        border: 2px solid #b71c1c;
        border-radius: 10px;
        background-color: #f44336;
        color: #fff;
        text-decoration: none;
        transition: background-color 0.3s, border-color 0.3s;
    }
    .remove-button:hover {
        background-color: #d32f2f;
        border-color: #b71c1c;
    }
</style>
</head>
<body>
<%
    if(session.getAttribute("user name") == null) {
        response.sendRedirect("index.jsp");
    }
    String username = (String) session.getAttribute("user name");

    try {
        ResultSet rs = DBconnector.readDBdata(username); // Adjust the method name and implementation as needed
%>
<div class="container">
    <div class="button-container">
        <a href="createDatabase.jsp" class="button">
            Create Database
        </a>
        <a href="restoreDatabase.jsp" class="button">
            Restore Database
        </a>
        <a href="downloadDatabase.jsp" class="button">
            Download Database
        </a>
    </div>
    <div class="installed-databases">
        <h2>Installed Databases</h2>
        <table>
            <tr>
                <th>Database Name</th>
                <th>Max Schemas</th>
                <th>Location</th>
                <th>Action</th>
            </tr>
            <%
                while(rs.next()) {
                    String dbName = rs.getString("db_name");
                    int maxSchemas = rs.getInt("max_schemas");
                    String location = rs.getString("location");
            %>
            <tr>
                <td><%= dbName %></td>
                <td><%= maxSchemas %></td>
                <td><%= location %></td>
                <td>
                    <form action="dbop" method="post">
                        <input type="hidden" name="ifdel" value="<%= dbName %>">
                        <button type="submit" class="remove-button">Delete</button>
                    </form>
                </td>
            </tr>
            <%
                }
            %>
        </table>
    </div>
</div>
<%
    } catch(Exception e) {
        e.printStackTrace();
    } 
%>
</body>
</html>
