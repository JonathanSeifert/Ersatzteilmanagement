import java.util.*;
import java.util.concurrent.TimeUnit;
import java.sql.*;


public class Anwendung2 {
	
	final static String user = "abteilungsleiter";
	final static String password = "prozess";
	final static String url = "jdbc:postgresql://localhost:5436/etm";
	
	public static void main (String[] args) {
		System.out.println("Ersatzteil- und Lieferantenverwaltung \n--------------------------------------");
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
		try {
			lieferanten(conn);
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		System.out.print("\n(INSERT-Beispiel)\nWollen sie einen Lieferanten hinzufügen?\n(j|n)");
		if (scan.next().toString().equals("j")) {
			try {
				insertLieferant(conn);
				disconnect(conn, scan);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		System.out.print("\n(DELETE-Beispiel)\nWollen Sie einen Lieferanten löschen?\n(j|n)");
		String choice = scan.next().toString();
		if (choice.equals("j")) {
			try {
				deleteLieferant(conn);
				disconnect(conn, scan);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		try {
			lieferanten(conn);
			System.out.println("\n");
			ersatzteile(conn);
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		System.out.print("\n(INSERT-Beispiel)\nWollen sie ein Ersatzteil hinzufügen?\n(j|n)");
		if (scan.next().toString().equals("j")) {
			try {
				insertErsatzteil(conn);
				disconnect(conn, scan);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		System.out.print("\n(DELETE-Beispiel)\nWollen Sie ein Ersatzteil löschen?\n(j|n)");
		choice = scan.next().toString();
		if (choice.equals("j")) {
			try {
				deleteErsatzteil(conn);
				disconnect(conn, scan);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		disconnect(conn, scan);
	}
		
	static void insertLieferant(Connection conn) throws SQLException {
		Scanner scan = new Scanner(System.in);
		System.out.println("Name: ");
		String name = scan.nextLine();
		gesamteStadtTabelle(conn);
		System.out.print("\nIst die Stadt in der Datenbank vorhanden?\n(j|n)");
		String choice = scan.nextLine();
		if (!choice.equals("j")) {
			System.out.println("Sie haben nicht die Berechtigung eine Stadt hinzuzufügen. Kontaktieren Sie die  IT-Abteilung.\nVorgang wird abgebrochen.\n");
			return;
		}
		else {
			System.out.print("Stadt_Id: ");
			int stadt_id = scan.nextInt();
			scan.nextLine();
				
			System.out.print("Anschrift: ");
			String anschrift = scan.nextLine();
			
			System.out.print("E-Mail: ");
			String email = scan.nextLine();
			
			System.out.print("Ansprechpartner: ");
			String ansprechpartner = "";
			ansprechpartner = scan.nextLine();

			//aktuellen Sequenzwert speichern
			int currval = 0;
			String SQLcurrval = "select lieferant_id from zustand1.lieferant order by lieferant_id desc limit 1;";		//Currval der Sequenz speichern
			PreparedStatement ps_currval = conn.prepareStatement(SQLcurrval);
			ResultSet rs_currval = ps_currval.executeQuery();
			if (rs_currval.next()) currval = rs_currval.getInt(1);
				
			String insert = "INSERT INTO zustand1.lieferant(lieferant_id, lieferant_name,"
					+ " stadt_id, anschrift, email, ansprechpartner) VALUES (default, ?, ?, ?, ?, ?)";
			PreparedStatement ps_insert = conn.prepareStatement(insert);
			ps_insert.setString(1, name);
			ps_insert.setInt(2, stadt_id);
			ps_insert.setString(3, anschrift);
			ps_insert.setString(4, email);
			ps_insert.setString(5, ansprechpartner);
			
			ps_insert.executeUpdate();
			
			String ausgabe = "select l.lieferant_name, l.anschrift, s.stadt_name, s.plz, l.email, l.ansprechpartner "
					+ "from zustand1.lieferant l join zustand1.stadt s on (s.stadt_id = l.stadt_id) "
					+ "where lieferant_id = currval('zustand1.lieferant_id_seq');";
			PreparedStatement ps_ausgabe = conn.prepareStatement(ausgabe);
			ResultSet rs = ps_ausgabe.executeQuery();
			
			System.out.println("\nIhre Eingaben:");
			while(rs.next()) {
				System.out.println("Name: 		 "+rs.getString(1));
				System.out.println("Anschrift:	 "+rs.getString(2));
				System.out.println("Stadt: 		 "+rs.getString(3));
				System.out.println("PLZ:		 "+rs.getString(4));
				System.out.println("Email: 		 "+rs.getString(5));
				System.out.println("Ansprechpartner: "+rs.getString(6));
			}
			System.out.println("\nEingaben bestätigen?\n(j|n)");
			choice = scan.next().toString();
			if (!choice.equals("j")) {
				System.out.println("Änderungen werden nicht übernommen.");
				String reset_seq = "select setval('zustand1.lieferant_id_seq',?);";
				PreparedStatement ps_reset_seq = conn.prepareStatement(reset_seq);
				ps_reset_seq.setInt(1, currval);
				ps_reset_seq.execute();
				String test = "select currval('zustand1.lieferant_id_seq');";
				PreparedStatement ps_test = conn.prepareStatement(test);
				ResultSet rs_test = ps_test.executeQuery();
				if(rs_test.next()) currval = rs_test.getInt(1);
				System.out.println(currval);
				
				return;
			}
			else {
				conn.commit();
				lieferanten(conn);
				System.out.println("Einfügen bestätigt.");
				return;
			}
		}
	}
	static void insertErsatzteil(Connection conn) throws SQLException {
		Scanner scan = new Scanner(System.in);
		lieferanten(conn);
		System.out.println("Ist der Lieferant in der Liste vorhanden?\n(j|n)");
		String choice = scan.next().toString();
		if (!choice.equals("j")) {
			System.out.println("Vorgang wird abgebrochen.");
			return;
		}
		else {
			System.out.print("Id:\n");
			int id = scan.nextInt();
			scan.nextLine();
			System.out.print("Modell: ");
			String modell = scan.next().toString();
			scan.nextLine();
			System.out.print("Preis pro Stück: ");
			double kosten = scan.nextDouble();
			scan.nextLine();
			eclass(conn);
			System.out.print("Ist die eClass-Kennung vorhanden?\n(j|n)");
			choice = scan.next().toString();
			if (!choice.equals("j")) {
				System.out.println("Sie haben nicht die Berechtigung eine eClass-Kennung hinzuzufügen. Kontaktieren Sie die IT-Abteilung."
						+ "\nVorgang wird abgebrochen.\n");
						return;
			}
			else {
				System.out.println("eClass (inkl. '-')");
				String eclass = scan.next().toString();
				priorisierung(conn);
				System.out.println("Ordnen Sie das Teil zu:\n(id)");
				String prio = scan.next().toString();
				
				//aktuellen Sequenzwert speichern
				int currval = 0;
				String SQLcurrval = "select e_id from zustand1.ersatzteil order by e_id desc limit 1;";		
				PreparedStatement ps_currval = conn.prepareStatement(SQLcurrval);
				ResultSet rs_currval = ps_currval.executeQuery();
				if (rs_currval.next()) currval = rs_currval.getInt(1);
				
				String insert = "INSERT INTO zustand1.ersatzteil(e_id, eclass, lieferant_id, kennzeichnung, kosten, p_id) values "
						+ "(default, ?, ?, ?, ?, ?);";
				PreparedStatement ps = conn.prepareStatement(insert);
				ps.setString(1, eclass);
				ps.setInt(2, id);
				ps.setString(3, modell);
				ps.setDouble(4, kosten);
				ps.setString(5, prio);
				
				ps.executeUpdate();
				
				String ausgabe = "select l.lieferant_name, e.kennzeichnung, ec.eclass_beschreibung, e.kosten, p.beschreibung "
						+ "from zustand1.ersatzteil e join zustand1.lieferant l on (l.lieferant_id = e.lieferant_id) "
													+ "join zustand1.eclass ec on (ec.eclass = e.eclass) join zustand1.priorisierung p on (p.p_id = e.p_id) "
						+ "where e_id = currval('zustand1.e_id_seq');";
				PreparedStatement ps_ausgabe = conn.prepareStatement(ausgabe);
				ResultSet rs = ps_ausgabe.executeQuery();
				
				System.out.println("\nIhre Eingaben:");
				while(rs.next()) {
					System.out.println("Lieferant: 		"+rs.getString(1));
					System.out.println("Modell:	 		"+rs.getString(2));
					System.out.println("eclass:			"+rs.getString(3));
					System.out.println("Preis:		 	"+rs.getDouble(4)+" €/Stück");
					System.out.println("Priorisierung:  	"+rs.getString(5));
				}
				System.out.println("Eingaben bestätigen?\n(j|n)");
				choice = scan.next().toString();
				if (!choice.equals("j")) {
					System.out.println("Änderungen werden nicht übernommen.");
					String reset_seq = "select setval('zustand1.e_id_seq',?);";
					PreparedStatement ps_reset_seq = conn.prepareStatement(reset_seq);
					ps_reset_seq.setInt(1, currval);
					ps_reset_seq.execute();
					String test = "select currval('zustand1.e_id_seq');";
					PreparedStatement ps_test = conn.prepareStatement(test);
					ResultSet rs_test = ps_test.executeQuery();
					if(rs_test.next()) currval = rs_test.getInt(1);
					System.out.println(currval);
					return;
				}
				else
				{
					conn.commit();
					System.out.println("Einfügen bestätigt.");
					return;
				}
				
			}
			
		}
	}
	static void deleteLieferant(Connection conn) throws SQLException{
		Scanner scan = new Scanner(System.in);
		//Ausgabe der Lieferanten
		lieferanten(conn);
		System.out.print("\nWelcher Lieferant (inkl. Ersatzteile) soll gelöscht werden?\n(lieferant_id) ");
		int lieferant_id = scan.nextInt();
		zugehoerigeTeile(conn, lieferant_id);
		String drop = "delete from zustand1.lieferant where lieferant_id = ?;";
		PreparedStatement ps_drop = conn.prepareStatement(drop);
		ps_drop.setInt(1, lieferant_id);
		System.out.println("Löschen bestätigen:\n(j|n)");
		String choice = scan.next().toString();
		if (!choice.contentEquals("j")) {
			lieferanten(conn);
			System.out.println("Löschen abgebrochen.");
			return;
		}
		else {
			ps_drop.executeUpdate();
			conn.commit();
			lieferanten(conn);
			System.out.println("Löschen bestätigt.\n");
			return;
		}
	}
	static void deleteErsatzteil(Connection conn) throws SQLException{
		Scanner scan = new Scanner(System.in);
		ersatzteile(conn);
		System.out.println("Welches Ersatzteil soll gelöscht werden?\n(modell)");
		String modell = scan.next().toString();
		String drop = "delete from zustand1.ersatzteil where kennzeichnung = ?";
		PreparedStatement ps = conn.prepareStatement(drop);
		ps.setString(1,modell);
		System.out.println("Löschen bestätigen:\n(j|n)");
		String choice = scan.next().toString();
		if (!choice.contentEquals("j")) {
			ersatzteile(conn);
			System.out.println("Löschen abgebrochen.");
			return;
		}
		else {
			ps.executeUpdate();
			conn.commit();
			ersatzteile(conn);
			System.out.println("Löschen bestätigt.\n");
			return;
		}
	}
	static void lieferanten(Connection conn) throws SQLException{
		System.out.println("Lieferanten\n");
		String lieferantGesamt = "select l.lieferant_id as id, l.lieferant_name as name, l.email, l.ansprechpartner"
				+ " from zustand1.lieferant l order by l.lieferant_id asc;";
		PreparedStatement ps_lieferantGesamt = conn.prepareStatement(lieferantGesamt);
		ResultSet rs = ps_lieferantGesamt.executeQuery();
		ResultSetMetaData rsmd = rs.getMetaData();
		int id_length = rsmd.getColumnDisplaySize(1);
		int name_length = rsmd.getColumnDisplaySize(2);
		int email_length = rsmd.getColumnDisplaySize(3);
		int ansprechpartner_length = rsmd.getColumnDisplaySize(4);

		
		System.out.format("%"+id_length+"s | %"+name_length+"s | %"+email_length+"s | %"+ansprechpartner_length+"s\n", rsmd.getColumnLabel(1),
						rsmd.getColumnLabel(2), rsmd.getColumnLabel(3), rsmd.getColumnLabel(4));
		while (rs.next()) {
			System.out.format("%"+id_length+"s | %"+name_length+"s | %"+email_length+"s | %"+ansprechpartner_length+"s\n", 
					rs.getInt(1),rs.getString(2), rs.getString(3),rs.getString(4));
		}
		System.out.println();
		return;
		
	}
	static void ersatzteile(Connection conn) throws SQLException{
		System.out.print("Ersatzteile\n");
		String ersatzteil_ausgabe = "select e.kennzeichnung as modell, l.lieferant_name as lieferant, e.kosten as kosten, ec.eclass_beschreibung as art "
				  + "from zustand1.ersatzteil e join zustand1.eclass ec on (e.eclass = ec.eclass) "
				  							 + "join zustand1.lieferant l on (l.lieferant_id = e.lieferant_id);";
		PreparedStatement ps_ersatzteil_ausgabe = conn.prepareStatement(ersatzteil_ausgabe); 
		ResultSet rs = ps_ersatzteil_ausgabe.executeQuery();
		ResultSetMetaData rsmd = rs.getMetaData();
		
		//Ausgabe der Ersatzteile
		//max. Spaltenbreite bestimmen
		int kennzeichnung_length = rsmd.getColumnDisplaySize(1);
		int lieferantname_length = rsmd.getColumnDisplaySize(2);
		int kosten_length = rsmd.getColumnDisplaySize(3);
		int eclassbeschreibung_length = rsmd.getColumnDisplaySize(4);
		System.out.format("%"+kennzeichnung_length+"s |%"+lieferantname_length+"s |%"+kosten_length+"s |%"+eclassbeschreibung_length+"s\n"
			,rsmd.getColumnLabel(1), rsmd.getColumnLabel(2), rsmd.getColumnLabel(3), rsmd.getColumnLabel(4));
		while (rs.next()) {
		String kennzeichnung = rs.getString(1);
		String lieferantname = rs.getString(2);
		double kosten = rs.getDouble(3);
		String eclassbeschreibung = rs.getString(4);
		System.out.format("%"+kennzeichnung_length+"s |%"+lieferantname_length+"s |%"+kosten_length+".2f€|%"+eclassbeschreibung_length+"s\n"
						,kennzeichnung, lieferantname, kosten, eclassbeschreibung);
		}
		System.out.println();
		return;
		
	}
	static void eclass(Connection conn) throws SQLException{
		System.out.println("Eclass\n");
		String eclassSQL = "select eclass, eclass_beschreibung as beschreibung from zustand1.eclass;";
		PreparedStatement ps = conn.prepareStatement(eclassSQL);
		ResultSet rs  = ps.executeQuery();
		ResultSetMetaData rsmd = rs.getMetaData();
		int eclass_length = rsmd.getColumnDisplaySize(1);
		int beschreibung_length = rsmd.getColumnDisplaySize(2);
		System.out.format("%"+eclass_length+"s | %"+beschreibung_length+"s\n", rsmd.getColumnLabel(1),rsmd.getColumnLabel(2));
		while (rs.next()) {
			String eclass = rs.getString(1);
			String beschreibung = rs.getString(2);
			System.out.format("%"+eclass_length+"s | %"+beschreibung_length+"s\n", eclass, beschreibung);
		}
		System.out.println();
		return;
		
	}
	static void priorisierung(Connection conn) throws SQLException{
		System.out.println("Priorisierung nach Lieferdauer\n");
		String prioSQL = "select p.p_id as id, p.beschreibung from zustand1.priorisierung p;";
		PreparedStatement ps = conn.prepareStatement(prioSQL);
		ResultSet rs = ps.executeQuery();
		ResultSetMetaData rsmd = rs.getMetaData();
		int id_length= rsmd.getColumnDisplaySize(1);
		int beschreibung_length = rsmd.getColumnDisplaySize(2);
		System.out.format("%"+id_length+"s | %s"+beschreibung_length+"\n", rsmd.getColumnLabel(1), rsmd.getColumnLabel(2));
		while (rs.next()) {
			String id = rs.getString(1);
			String beschreibung = rs.getString(2);
			System.out.format("%"+id_length+"s  | %"+beschreibung_length+"s\n", id, beschreibung);
		}
		System.out.println();
		return;
	}
	static void zugehoerigeTeile(Connection conn, int lieferant_id) throws SQLException {
		System.out.println("Zugehörige Ersatzteile: \n");
		String ausgabe = "select e.kennzeichnung, e.kosten, ec.eclass_beschreibung"
				+ " from zustand1.lieferant l join zustand1.ersatzteil e on (e.lieferant_id = l.lieferant_id)"
											+ "join zustand1.eclass ec on (ec.eclass = e.eclass)"
				+ " where l.lieferant_id = ?";
		PreparedStatement ps_ausgabe = conn.prepareStatement(ausgabe);
		ps_ausgabe.setInt(1, lieferant_id);
		ResultSet rs_ausgabe = ps_ausgabe.executeQuery();
		ResultSetMetaData rsmd = rs_ausgabe.getMetaData();
		int modell_length = rsmd.getColumnDisplaySize(1);
		int kosten_length = rsmd.getColumnDisplaySize(2);
		int eclass_length = rsmd.getColumnDisplaySize(3);

		
		System.out.format("%"+modell_length+"s | %"+kosten_length+"s | %"+eclass_length+"s\n",
							rsmd.getColumnLabel(1), rsmd.getColumnLabel(2), rsmd.getColumnLabel(3));
		while(rs_ausgabe.next()) {
			System.out.format("%"+modell_length+"s | %"+kosten_length+".2f | %"+eclass_length+"s\n",
					rs_ausgabe.getString(1), rs_ausgabe.getDouble(2), rs_ausgabe.getString(3));
		}
		System.out.println();
		//System.out.format("%s | %s | %s | %s", arg1)
	}
	static void gesamteStadtTabelle(Connection conn) throws SQLException{
		System.out.println("\nStädte\n(Stadt_Id, Regierungsbezirk_Id, Name, Plz\n");
		String gesamt = "select * from zustand1.stadt;";
		PreparedStatement ps_gesamt = conn.prepareStatement(gesamt);
		ResultSet rs = ps_gesamt.executeQuery();
		System.out.println();
		while(rs.next()) {
				System.out.print(rs.getInt(1)+"	|");
				System.out.print(rs.getString(2)+"	|");
				System.out.print(rs.getString(4)+"	|");
				System.out.println(rs.getString(3));
		}
	}	
	static void disconnect(Connection conn, Scanner scan) {
		System.out.println("Anwendung wird beendet. Von Datenbank trennen...");
		try {
			conn.close();
			TimeUnit.MILLISECONDS.sleep(1250);
		} catch (SQLException | InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("Erfolgreich von Datenbank getrennt.");
		scan.close();
		System.exit(1);
		
	}
}