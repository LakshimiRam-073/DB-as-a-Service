
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.connect.DBconnector;

/**
 * Servlet implementation class CreateDB
 */


public class DBops extends HttpServlet {
	private static final long serialVersionUID = 1L;
	public String serverIp = "10.16.47.241";
	private int port = 9090;
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("text/html");
		HttpSession sess = request.getSession();

		String uname = (String) sess.getAttribute("user name");// session use
		String pass = (String) sess.getAttribute("password");// session use
		String dbName = (String) request.getParameter("database name");
		String isDel = (String) request.getParameter("ifdel");
		int numschemas = 2 ;//default;
		int backupInterval = 12;// default
		if(isDel == null)
		{
			 backupInterval = Integer.parseInt(request.getParameter("backup interval"));
			 numschemas = Integer.parseInt(request.getParameter("numschemas"));
		}

		String server = "/home/lakshimi-pt7619/server/dbusers/";
		
		// init
		ProcessBuilder pb = new ProcessBuilder();
		pb.inheritIO();
		File f = new File(server);
		pb.directory(f);
		List<String> commands = new ArrayList<String>();
		commands.add("sh");
		commands.add("-c");
		System.out.println(isDel);
		// commands
		String dbop;
		if(isDel ==null)
			dbop= String.format("./create_deletedb.sh -nsch %d -db_name %s -user %s -pass %s", numschemas,
				dbName, uname, pass);
		else
			dbop =  String.format("./create_deletedb.sh -db_name %s -delete yes",
					isDel);
		String combined = String.join("&&", dbop);
		commands.add(combined);

		PrintWriter pw = response.getWriter();
		processCommands(commands, pb, pw,isDel,uname,dbName);

		// sql
		
		if(isDel==null)
		{
			try {
				DBconnector.addDB(uname, dbName, numschemas,server);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		else {
			try {
				DBconnector.deleteDB(uname, isDel);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}

	}

	private void processCommands(List<String> commands, ProcessBuilder pb, PrintWriter pw,String ifDel,String uname,String dbname) {

		pb.command(commands);
		
		// process start
		try {
			Process process = pb.start();
			printProcess(process);
			int exitcode = process.waitFor();
			if (exitcode != 0) {
				pw.println("Error Occurred: Something went wrong.");

			} else {
				if(ifDel==null)
				{
					pw.println("Process completed successfully.<br>");
					//Eiter use ip and pass
//					pw.println("Your Ip is "+serverIp+"<br>");
//					pw.println("Username and password is same as Yours. <br>Login with port Number "+port+"<br>");
					//or as a link
//					pw.println(String.format("Use \"psql postgres://%s:Your-password-here@%s:%d/%s\"<br>", uname,serverIp,port,dbname));
					String clientcert = String.format("/home/lakshimi-pt7619/.postgresql/%s/client.crt",uname);
					String clientkey = String.format("/home/lakshimi-pt7619/.postgresql/%s/client.key",uname);
					String rootCA = "/home/lakshimi-pt7619/.postgresql/root.crt";
					pw.println(String.format("psql \"postgresql://%s:|your password here|@%s:%d/%s?sslmode=require&sslcert=%s&sslkey=%s&sslrootcert=%s\"<br>"
	, uname,serverIp,port,dbname,clientcert,clientkey,rootCA));
					pw.println("<a href=\"options.jsp\">Link to options</a>");
				}
				else
				{
					pw.println("<meta http-equiv=\"refresh\" content=\"3;url=databaseUsers.jsp\" />");
					pw.println("Process completed successfully.....Refreshing");					
				}
					
					

			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			System.out.println(e.getMessage());
			pw.println("Error Occured:Something went wrong.");
			pw.println("Error " + e.getMessage());
		}
	}

	private static void printProcess(Process process) throws Exception {

		// process printing
		InputStream ip = process.getInputStream();
		InputStream ep = process.getErrorStream();
		try {
			printStream(ip);
			printStream(ep);

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			process.waitFor();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	private static void printStream(InputStream inputStream) throws IOException {
		System.out.println("Postgres Stream");
		try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream))) {
			String line;
			while ((line = bufferedReader.readLine()) != null) {
				System.out.println(line);
			}
		}
	}

}
