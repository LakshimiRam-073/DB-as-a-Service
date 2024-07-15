<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Success Page</title>
</head>
<body>
    <% 
        if (session.getAttribute("user name") == null) {
            response.sendRedirect("index.jsp");
            return; 
        }
    
        Boolean loading = (Boolean) session.getAttribute("loading");
        if (loading != null && loading.booleanValue()) {
   
        String load = "<h1>Loading...</h1>";
        out.println(load);
    } else { 

        String load = "<h1>Success...</h1>";
        out.println(load);
   } %>
</body>
</html>
