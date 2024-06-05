package org.example;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class InserirDados {

    // Dados de conexão
    private static final String DB_URL = "jdbc:oracle:thin:@oracle.fiap.com.br:1521:orcl";
    private static final String DB_USER = "rm97121";
    private static final String DB_PASSWORD = "290603";

    public static void main(String[] args) {
        Connection conn = null;
        CallableStatement stmt = null;

        try {
            // Registrar o driver JDBC
            DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());

            // Estabelecer a conexão
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            conn.setAutoCommit(false); // Desabilita o commit automático

            // Inserir Porto
            execProcedure(conn, "manage_destino('INSERT', 123, 'Porto Marítimo')");

            // Inserir Localização
            execProcedure(conn, "manage_localizacao('INSERT', 123, 45678, 123, 123)");

            // Inserir Operação Lastro
            execProcedure(conn, "manage_operacao_lastro('INSERT', 123, 123, TIMESTAMP '2024-06-04 16:22:20.235765', 123)");

            // Inserir Monitoramento Operação
            execProcedure(conn, "manage_monitoramento_operacao('INSERT', 1, 'Nome Métrica', 100, 123)");

            // Inserir Navio
            execProcedure(conn, "manage_navio('INSERT', 133, 'Navio A', 133, 1)");

            // Inserir Tipo Navio
            execProcedure(conn, "manage_tipo_navio('INSERT', 1, 'Tipo A', 133)");

            // Inserir Tipo Operação
            execProcedure(conn, "manage_tipo_operacao('INSERT', 1, 'Operação A', 123)");

            // Inserir Histórico Localização
            execProcedure(conn, "manage_historico_localizacao('INSERT', 1, TIMESTAMP '2024-06-04 16:22:20.235765', 1, 133, 123)");

            conn.commit(); // Confirmar todas as operações
            System.out.println("Inserções realizadas com sucesso.");
        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private static void execProcedure(Connection conn, String procedureCall) throws SQLException {
        String sql = "BEGIN " + procedureCall + "; END;";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.execute();
        }
    }
}
