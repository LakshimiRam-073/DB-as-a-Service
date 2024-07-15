<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.connect.DBconnector" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Cluster Services</title>
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
    .installed-clusters {
        flex-grow: 1;
        background-color: #ffffff;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }
    .installed-clusters h2 {
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
    .delete-form {
        display: inline;
    }
    .delete-button {
        background-color: #f44336;
        color: white;
        border: none;
        padding: 8px 16px;
        text-align: center;
        text-decoration: none;
        display: inline-block;
        font-size: 14px;
        margin: 4px 2px;
        cursor: pointer;
        border-radius: 8px;
        transition: background-color 0.3s;
    }
    .delete-button:hover {
        background-color: #d32f2f;
    }
</style>
</head>
<body>
<%
    if(session.getAttribute("user name") == null) {
        response.sendRedirect("index.jsp");
    }
    String username = (String)session.getAttribute("user name");

    try {
        ResultSet rs = DBconnector.readClustData(username);
%>
<div class="container">
    <div class="button-container">
        <a href="createCluster.jsp" class="button">
            Create Cluster
        </a>
        <a href="restore-cluster" class="button">
            Restore Cluster
        </a>
        <a href="download-cluster" class="button">
            Download Cluster
        </a>
    </div>
    <div class="installed-clusters">
        <h2>Installed Clusters</h2>
        <table>
            <tr>
                <th>Cluster Name</th>
                <th>Cluster Location</th>
                <th>Replication Count</th>
                <th>Version</th>
                <th>Port Number</th>
                <th>Actions</th>
            </tr>
            <%
                while(rs.next()) {
                    String clusterName = rs.getString("clust_name");
                    String clusterloc = rs.getString("location");
                    int repcount = rs.getInt("repcount");
                    String version = rs.getString("version");
                    int portnumber = rs.getInt("port_number");
            %>
            <tr>
                <td><%= clusterName %></td>
                <td><%= clusterloc %></td>
                <td><%= repcount %></td>
                <td><%= version %></td>
                <td><%= portnumber %></td>
                <td>
                    <form class="delete-form" action="deleteCluster" method="post">
					    <input type="hidden" name="clusterName" value="<%= clusterName %>" />
					    <input type="hidden" name="port" value="<%= portnumber %>" />
					    <input type="hidden" name="repcount" value="<%= repcount %>" />
					    <input type="hidden" name="location" value="<%= clusterloc %>" />
					    <button type="submit" class="delete-button">Delete</button>
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
