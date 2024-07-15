
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import com.connect.DBconnector;

/**
 * Servlet implementation class LoginServlet
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String username = request.getParameter("user name");
		String password = request.getParameter("password");
		HttpSession sess = request.getSession();
		try {
			if (DBconnector.authUser(username, password)) {
				response.sendRedirect("options.jsp");
				sess.setAttribute("loginstatus", true);
				sess.setAttribute("showmessage", false);
				sess.setAttribute("user name", username);
				System.out.println("login:" + username);
				sess.setAttribute("password", password);
			} else {
				sess.setAttribute("showmessage", true);
				response.sendRedirect("index.jsp");
			}

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}
