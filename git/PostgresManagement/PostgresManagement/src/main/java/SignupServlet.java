

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

import com.connect.DBconnector;
@WebServlet("/signup")
public class SignupServlet extends HttpServlet {
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        if (!password.equals(confirmPassword)) {
            request.setAttribute("showErrorMessage", true);
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        try {
			if (DBconnector.getUserId(username)!= -1) {
			    request.setAttribute("showErrorMessage", true);
			    request.getRequestDispatcher("signup.jsp").forward(request, response);
			    return;
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        boolean success= false;
        try {
			 success = DBconnector.insertUser(username, password);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        HttpSession sess = request.getSession();
        if(success)
        {
        	sess.setAttribute("user name", username);
        	sess.setAttribute("password", password);
        	response.sendRedirect("options.jsp");
        	
        }
        else {
        	request.setAttribute("showErrorMessage", true);
        	request.getRequestDispatcher("signup.jsp").forward(request, response);

        }
	}

}
