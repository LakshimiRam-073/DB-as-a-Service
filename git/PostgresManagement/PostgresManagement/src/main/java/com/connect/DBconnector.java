package com.connect;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DBconnector {

	static final String url = "jdbc:postgresql://localhost:5432/postgres";
	static final String username = "postgres";
	static final String pass = "postgres";

	public static Connection connector() throws SQLException, Exception {

		Class.forName("org.postgresql.Driver");
		Connection con = DriverManager.getConnection(url, username, pass);
		return con;

	}

	public static boolean addInstanceCluster(String user, String clustname, int backup, String version, int repcount)
			throws SQLException, Exception {
		String addInstance = "Insert into cluster_table values(?,?,?,?,?,?)";
		Connection con = DBconnector.connector();
		PreparedStatement ps = con.prepareStatement(addInstance);
		int id = getUserId(user);
		if (id == -1)
			return false;
		// Need to implement
		return false;
	}

	public static int getUserId(String user) throws Exception {
		Connection con = DBconnector.connector();
		Statement sq = con.createStatement();
		ResultSet rs = sq.executeQuery("select uid from user_table where username='" + user + "'");
		if (!rs.next())
			return -1;
		return rs.getInt(1);
	}
	public static boolean insertUser(String user, String password) throws SQLException, Exception
	{
		Connection con = DBconnector.connector();
		String query = "INSERT INTO user_table(username,password) VALUES(?,?)";
		PreparedStatement ps = con.prepareStatement(query);
		ps.setString(1, user);
		ps.setString(2, password);
		int rowsAff = ps.executeUpdate();
		if(rowsAff>=1) return true;
		return false;
		
	}
	public static boolean authUser(String user, String password) throws Exception {
		String query = "SELECT * FROM user_table where username=? and password=?";
		Connection con = connector();
		PreparedStatement ps = con.prepareStatement(query);
		ps.setString(1, user);
		ps.setString(2, password);

		ResultSet rs = ps.executeQuery();
		if (rs.next())
			return true;
		return false;

	}
	public static ResultSet readClustData(String username) throws SQLException, Exception {
		Connection con = DBconnector.connector();
		int uid = -1;
		try {
			uid = DBconnector.getUserId(username);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String query = "SELECT clust_name,location,repcount,version,port_number FROM cluster_table WHERE uid=?";
		PreparedStatement ps = con.prepareStatement(query);
		ps.setInt(1, uid);
		ResultSet rs = ps.executeQuery();

		return rs;

	}
	
	public static ResultSet readDBdata(String username) throws SQLException, Exception {
		Connection con = DBconnector.connector();
		int uid = -1;
		try {
			uid = DBconnector.getUserId(username);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String query = "SELECT db_name,max_schemas,location FROM db_users_table WHERE uid=?";
		PreparedStatement ps = con.prepareStatement(query);
		ps.setInt(1, uid);
		ResultSet rs = ps.executeQuery();

		return rs;

	}

	public static boolean addCluster(String username, String location, int repcount, String clustname, String version,
			int port) throws SQLException, Exception {

		int uid = -1;
		try {
			uid = DBconnector.getUserId(username);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Connection con = DBconnector.connector();
		System.out.println(uid);
		String query = "insert into cluster_table(uid,location,repcount,clust_name,version,port_number)"
				+ " values(?,?,?,?,?,?);";
		PreparedStatement pre = con.prepareStatement(query);
		pre.setInt(1, uid);
		pre.setString(2, location);
		pre.setInt(3, repcount);
		pre.setString(4, clustname);
		pre.setString(5, version);
		pre.setInt(6, port);

		int rowsAff = pre.executeUpdate();
		if (rowsAff == 0)
			return false;
		return true;
	}
	public static boolean deleteDB(String username,String db_name) throws SQLException, Exception
	{
		int uid = -1;
		try {
			uid = DBconnector.getUserId(username);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Connection con = DBconnector.connector();
		System.out.println(uid);
		System.out.println(db_name);
		String query = "DELETE from db_users_table where uid=? and db_name=?";
		PreparedStatement ps = con.prepareStatement(query);
		ps.setInt(1, uid);
		ps.setString(2, db_name);
		
		int rowsAff = ps.executeUpdate();
		if (rowsAff == 0)
			return false;
		return true;
	}

	public static boolean addDB(String username, String db_name, int max_schemas,String location) throws SQLException, Exception {

		int uid = -1;
		try {
			uid = DBconnector.getUserId(username);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Connection con = DBconnector.connector();
		System.out.println(uid);
		String query = "insert into db_users_table" + " values(?,?,?,?);";
		PreparedStatement pre = con.prepareStatement(query);
		pre.setInt(1, uid);
		pre.setInt(2, max_schemas);
		pre.setString(3, db_name);
		pre.setString(4, location);
		int rowsAff = pre.executeUpdate();
		if (rowsAff == 0)
			return false;
		return true;
	}
	public static boolean deleteCluster(String username,String clusterName,int port,int replicaCount) throws SQLException, Exception
	{
		
		/// need to optimize in query
		int uid = -1;
		try {
			uid = DBconnector.getUserId(username);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		Connection con = DBconnector.connector();
		System.out.println(uid);
		while(replicaCount>=1)
		{
			String sel_quer = "SELECT to_port from replication_heirarchy WHERE from_port=?";
			PreparedStatement ps = con.prepareStatement(sel_quer);
			ps.setInt(1, port);	
			ResultSet rs = ps.executeQuery();
			rs.next();
			int newPort = rs.getInt("to_port");
			
			String del_query = "DELETE FROM replication_heirarchy WHERE from_port=?";
			ps = con.prepareStatement(del_query);
			ps.setInt(1, port);
			port=newPort;
			ps.executeUpdate();
			replicaCount--;
		}
		String query = "DELETE FROM cluster_table WHERE uid=? AND clust_name=?";
		PreparedStatement ps = con.prepareStatement(query);
		ps.setInt(1, uid);
		ps.setString(2, clusterName);
		int rowsAff = ps.executeUpdate();
		if(rowsAff<1)
			return false;
		return true;
		
		
			
		
	}

}
