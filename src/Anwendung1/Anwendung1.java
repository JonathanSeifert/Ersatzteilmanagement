package dbp20;

import java.util.*;
import java.util.Date;
import java.sql.*;


public class Anwendung1 {
	
	final static String user = "lagerist";
	final static String password = "logistik";
	final static String url = "jdbc:postgresql://localhost:5436/etm";
	
	public static void main (String[] args) {
		System.out.println("Ersatzteillager-Aktualisierung \n------------------------------");
		Scanner scan = new Scanner(System.in);
		Connection conn = null;
		try {
			conn = DriverManager.getConnection(url, user, password);
			conn.setAutoCommit(false);
			System.out.println("Erfolgreich mit Datenbank verbunden.");
			System.out.println("Auto-Commit Modus: " + conn.getAutoCommit()+"\n");
		}
		catch (SQLException e) {
			System.out.print(e.getMessage());
			System.exit(1);
		}
		String lager_ausgabe = "select lager_id as Lager_Id, lager_name as Name from zustand1.lager;";
		try (PreparedStatement ps = conn.prepareStatement(lager_ausgabe)){
			ResultSet rs = ps.executeQuery();
			ResultSetMetaData rsmd = rs.getMetaData();
			int colNum = rsmd.getColumnCount();
			System.out.println(rsmd.getColumnName(1)+"|"+rsmd.getColumnName(2));
			while (rs.next()) {
				for (int i=1; i< colNum; i++) {
					if(i>1) System.out.print(" | ");
					String colValue1 = rs.getString(1);
					String colValue2 = rs.getString(2);
					System.out.println(colValue1 + "	|" + colValue2);
				}
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("(UPDATE-Beispiel)\nIn welchem Lager möchten Sie Änderungen vornehmen?");
		System.out.print("(lager_id) ");
		final String lager = scan.next().toString();
		
		try {
			lagersituation(conn, lager);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
			
		
		System.out.print("\nMöchten sie die Anzahl eines bestehenden Ersatzteils ändern?\n(j|n)");
		String choice = scan.next().toString();
		if (choice.equals("j")) {
			System.out.print("\nUm welches Ersatzteil handelt es sich?\n(e_id)");
			int e_id = scan.nextInt();
			System.out.print("Änderung des Bestands auf: ");
			int anzahl = scan.nextInt();
			try {
				updateLagerortEid(conn, lager, e_id, anzahl);
				
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			
			System.out.println("Erfolgreich von der Datenbank getrennt.");
			System.exit(1);
					
		}
		else {
			System.out.println("Erfolgreich von der Datenbank getrennt.");
			System.exit(1);
		}
	}
	static void updateLagerortEid(Connection conn, String lager_id, int e_id, int anzahl) throws SQLException{
		//Zeile aktualisieren
		String update = "update zustand1.lagerort set anzahl = ? where e_id = ?;";
		PreparedStatement ps_update = conn.prepareStatement(update);
		ps_update.setInt(1, anzahl);
		ps_update.setInt(2, e_id);
		ps_update.executeUpdate();
		
		String ps_lager = "select lo.anzahl, lo.mindestbestand, e.kennzeichnung, l.lieferant_name, e.e_id "
				+ "from zustand1.lagerort lo join zustand1.ersatzteil e on (e.e_id = lo.e_id) "
				+ "join zustand1.lieferant l on (e.lieferant_id = l.lieferant_id) "
				+ "where lager_id = ?;";
		PreparedStatement nachUpdate = conn.prepareStatement(ps_lager);
		nachUpdate.setString(1, lager_id);
		ResultSet rs = nachUpdate.executeQuery();
		lagersituation(conn, lager_id);
	
		Scanner scan = new Scanner(System.in);
		System.out.println("\nÄnderungen bestätigen?\n(j|n)");
		String choice = scan.next().toString();
		if (choice.equals("j")){
			conn.commit();
			System.out.println("Änderungen bestätigt.");
			return;
		}
		System.out.print("Änderungen rückgängig gemacht.");
		return;
	}
	static void lagersituation(Connection conn, String lager) throws SQLException{
		System.out.println("\nAktuelle Situation im Lager "+lager);
		System.out.println("ab = aktueller Bestand, mb = Mindestbestand");
		String SQL = "select lo.anzahl as ab, lo.mindestbestand as mb, e.kennzeichnung, l.lieferant_name, e.e_id as id, lo.letzter_abgang, lo.letzter_zugang "
				+ "from zustand1.lagerort lo join zustand1.ersatzteil e on (e.e_id = lo.e_id) "
								+ "join zustand1.lieferant l on (e.lieferant_id = l.lieferant_id) "
				+ "where lager_id = ?;";
		PreparedStatement ps = conn.prepareStatement(SQL);
		ps.setString(1, lager);
		ResultSet rs = ps.executeQuery();
		ResultSetMetaData rsmd = rs.getMetaData();
		
		int anzahl_length = rsmd.getColumnDisplaySize(1);
		int mindestbestand_length = rsmd.getColumnDisplaySize(2);
		int kennzeichnung_length = rsmd.getColumnDisplaySize(3)-15;
		int lieferant_length = rsmd.getColumnDisplaySize(4);
		int eid_length = rsmd.getColumnDisplaySize(5);
		int abgang_length = rsmd.getColumnDisplaySize(6);
		int zugang_length = rsmd.getColumnDisplaySize(7);
		
		System.out.format("%"+eid_length+"s | %"+anzahl_length+"s | %"+mindestbestand_length+"s | %"+kennzeichnung_length+"s | %"
					+lieferant_length+"s | %"+abgang_length+"s | %"+zugang_length+"s\n", rsmd.getColumnLabel(5), rsmd.getColumnLabel(1), rsmd.getColumnLabel(2), rsmd.getColumnLabel(3), 
				rsmd.getColumnLabel(4), rsmd.getColumnLabel(6), rsmd.getColumnLabel(7));
		
		while(rs.next()) {
			int anzahl = rs.getInt(1);
			int mindestbestand = rs.getInt(2);
			String kennzeichnung = rs.getString(3);
			String lieferant = rs.getString(4);
			int e_id = rs.getInt(5);
			String abgang = rs.getString(6);
			String zugang = rs.getString(7);
			
			System.out.format("%"+eid_length+"s | %"+anzahl_length+"s | %"+mindestbestand_length+"s | %"+kennzeichnung_length+"s | %"
					+lieferant_length+"s | %"+abgang_length+"s | %"+zugang_length+"s\n", e_id, anzahl, mindestbestand, kennzeichnung, 
					lieferant, abgang, zugang);
		}
		System.out.println();
	}
}
