<?php

	
	usleep(500000);
	if(isset($_POST["password"]) && isset($_POST["username"])){

		try {
			$user = "root";
			$pass = "";
			$host = "localhost";
			$dbname = "azerron_database";
			$db = new PDO("mysql:host=$host;dbname=$dbname", $user, $pass);
			$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		}
		catch(PDOException $e) { 
			echo 'success=false&error=0001';
			//echo $e->getMessage();  
		}  
		//--------

		$username = $_POST["username"];
		$password = $_POST["password"];


		$stmt = $db->prepare('SELECT * FROM characters WHERE username = :user');
		$stmt->bindParam(':user', $username, PDO::PARAM_INT);
		$stmt->execute();

		$result = $stmt->fetchAll();
		$count = count($result);
		if ($count == 1) {
			foreach($result as $row) {
				$hashedPass = md5($password);
				$userAccess = $row["access"];
				if($row["password"] === $hashedPass){
					if($userAccess < 1){
						echo 'success=false&error=banned';
						exit();
					}
					
					echo "success=true";// . "&";
					
					
					$stmt = $db->prepare('SELECT * FROM servers');
					$stmt->execute();

					$result = $stmt->fetchAll();
					$count = count($result);
					
					$i = 0;
					foreach($result as $server) {
						$name = $server["serverName"];
						$ip = $server["serverIP"];
						$port = $server["serverPort"];
						$isOnline = $server["isOnline"];
						$serverAccess = $server["serverAccess"];
						
						if($isOnline == 1 && $userAccess >= $serverAccess){
							$i ++;
							echo "&" . "serverName$i=$name";
							echo "&" . "serverIP$i=$ip";
							echo "&" . "serverPort$i=$port";
						}
					}
					echo "&" . "serverCount=$i";
					
					
					
					
				} else {
					echo 'success=false&error=login_failed';
				}
			}   
		} else {
			echo "success=false&error=login_failed";
		}
	} else {
		echo 'success=false&error=no_data';
	}


	exit;
?>