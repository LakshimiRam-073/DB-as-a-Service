
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
import java.net.ServerSocket;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.connect.DBconnector;

@WebServlet("/createclust")
public class CreateCluster extends HttpServlet {
	public String serverIp = "10.16.47.241";
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("text/html");
		HttpSession sess = request.getSession();
		String uname = (String) sess.getAttribute("user name");// session use
		String pass = (String) sess.getAttribute("password");// session use
		System.out.println(pass +" is the password");
		sess.setAttribute("loading", true);
		String clustName = (String) request.getParameter("clust name");
		int backupInterval = Integer.parseInt(request.getParameter("backup interval"));
		String version = (String) request.getParameter("version");
		int repcount = Integer.parseInt(request.getParameter("replication count"));
		int port = portGiver(5000, 8000);
		System.out.println(uname);
		// printing for debug

//		PrintWriter pw = response.getWriter();
//		pw.println(uname);
//		pw.println(pass);
//		pw.println(clustName);
//		pw.println(backupInterval);	
		
		
		// server directory
		String server = "/home/lakshimi-pt7619/server/clustusers";
		// init for
		ProcessBuilder pb = new ProcessBuilder();
		pb.inheritIO();
		File f = new File(server);
		pb.directory(f);
		List<String> commands = new ArrayList<String>();
		commands.add("sh");
		commands.add("-c");

		// commands
		String debug = "pwd";
		String initialize = String.format("./initial.sh %s", clustName);
		String install = String.format("./install_instance.sh %s %s ", version, clustName);
		System.out.println(pass);
		String instanciate = String.format("./instance_cluster.sh -clust_name %s -user %s -pass %s -rep %d -port %d",
				clustName, uname, pass, repcount, port);
		System.out.println(instanciate);
		// combined
		String combined = String.join("&&", debug, initialize, install, instanciate);
		commands.add(combined);
		// process builder -> in Terminal
		PrintWriter pw = response.getWriter();
		request.getRequestDispatcher("loading.jsp");
		processCommands(commands, pb, pw,port,uname);
		// sql
		try {
			DBconnector.addCluster(uname, server + "/" + clustName, repcount, clustName, version, port);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	private void processCommands(List<String> commands, ProcessBuilder pb, PrintWriter pw,int port,String uname) {
		pb.command(commands);
		
		// process start
		try {
			Process process = pb.start();
//			printProcess(process);
			int exitcode = process.waitFor();
			if (exitcode != 0) {
				pw.println("Error Occurred: Something went wrong.");

			} else {
				pw.println("Process completed successfully.<br>");
				//Eiter use ip and pass
//				pw.println("Your Ip is "+serverIp+"<br>");
//				pw.println("Username and password is same as Yours \nLogin with port Number "+port+"<br>");
				// or as a link
				String clientcert = String.format("/home/lakshimi-pt7619/.postgresql/%s/client.crt",uname);
				String clientkey = String.format("/home/lakshimi-pt7619/.postgresql/%s/client.key",uname);
				String rootCA = "/home/lakshimi-pt7619/.postgresql/root.crt";
				pw.println(String.format("psql \"postgresql://%s:|your password here|@%s:%d/postgres?sslmode=require&sslcert=%s&sslkey=%s&sslrootcert=%s\"<br>"
, uname,serverIp,port,clientcert,clientkey,rootCA));
				pw.println("<a href=\"options.jsp\">Link to options </a>");
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

	private int portGiver(int start, int end) {
		for (int i = start; i <= end; i++) {
			if (helper(i))
				return i;

		}
		return -1;
	}

	private boolean helper(int port) {
		try (ServerSocket serverSocket = new ServerSocket(port)) {
			// If we can bind to the port, it's available
			return true;
		} catch (IOException e) {
			// If an IOException is thrown, the port is not available
			return false;
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
