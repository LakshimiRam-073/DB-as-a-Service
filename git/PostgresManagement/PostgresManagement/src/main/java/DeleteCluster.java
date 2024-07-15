

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
import java.util.ArrayList;
import java.util.List;

import com.connect.DBconnector;

/**
 * Servlet implementation class DeleteCluster
 */
public class DeleteCluster extends HttpServlet {
	private static final long serialVersionUID = 1L;
    
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		response.setContentType("text/html");
		HttpSession sess = request.getSession();

		String uname = (String) sess.getAttribute("user name");// session use
		String pass = (String) sess.getAttribute("password");// session use
		String clustName = (String) request.getParameter("clusterName");
		System.out.println(clustName);
		int repcount = Integer.parseInt((String)request.getParameter("repcount"));
		int port = Integer.parseInt((String) request.getParameter("port"));
		String server = "/home/lakshimi-pt7619/server/clustusers";
		
		
		 //init
		ProcessBuilder pb = new ProcessBuilder();
		pb.inheritIO();
		File f = new File(server);
		pb.directory(f);
		List<String> commands = new ArrayList<String>();
		commands.add("sh");
		commands.add("-c");
		
		//commands
		String deleteCluster = String.format("./del_cluster.sh %s %d",server+"/"+clustName,repcount);
		
		String combined = String.join("&&", deleteCluster);
		commands.add(combined);

		PrintWriter pw = response.getWriter();
		processCommands(commands, pb, pw);
		
		try {
			DBconnector.deleteCluster(uname, clustName, port, repcount);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	
	
	private void processCommands(List<String> commands, ProcessBuilder pb, PrintWriter pw) {

		pb.command(commands);

		// process start
		try {
			Process process = pb.start();
			printProcess(process);
			int exitcode = process.waitFor();
			if (exitcode != 0) {
				pw.println("Error Occurred: Something went wrong.");

			} else {
				pw.println("<meta http-equiv=\"refresh\" content=\"3;url=clustUsers.jsp\" />");
				pw.println("Process completed successfully.....Refreshing");
				

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
