import net
import os
import io
import time

fn client(mut conn net.TcpConn) {
	println("Client has connected, begin chatting!")
	for {
		input := os.input("Type: ")
		conn.write_string("\rMessage from client: ${input}\nType: ") or {0}
	}
}

fn server(mut conn net.TcpConn) {
	conn.write_string("You have connected to the server, begin chatting!\n\n") or {0}
	conn.set_read_timeout(10 * time.minute)
	go client(mut conn)
	mut reader := io.new_buffered_reader(reader: conn)
	for {
		conn.write_string("Type: ") or {0}
		input := reader.read_line() or {eprintln("Socket timed out") return}
		print("\rMessage from server: ${input}\nType: ")
	}
}

fn main() {
	port := os.args[1] or {eprintln("Missing args | port") return}

	mut create_connection := net.listen_tcp(.ip6, ":${port}") or {eprintln("Failed to create server") return}
	println("Server created on ${port}\nAwaiting the client connection...\n")

	mut conn := create_connection.accept() or {eprintln("Failed to accept") return}
	server(mut conn)
}