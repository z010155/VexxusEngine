<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Azerron ACP</title>

    <!-- Bootstrap core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/signin.css" rel="stylesheet">

    <!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
    <!--[if lt IE 9]><script src="../../assets/js/ie8-responsive-file-warning.js"></script><![endif]-->
    <script src="js/ie-emulation-modes-warning.js"></script>

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

<?php
	if(isset($_POST["password"]) && isset($_POST["username"])){

		try {
			$user = "azerron";
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


		$stmt = $db->prepare('SELECT * FROM characters WHERE username = :user LIMIT 1');
		$stmt->bindParam(':user', $username, PDO::PARAM_STR);
		$stmt->execute();

		$result = $stmt->fetchAll();
		$count = count($result);
		if ($count == 1) {
			foreach($result as $row) {
				$hashedPass = md5($password);
				$userAccess = $row["access"];
				if($row["password"] === $hashedPass){
                    if($userAccess > 3){
                        setcookie("username", $username, time() + 3600, "/");
                        setcookie("password", $hashedPass, time() + 3600, "/");
                        header("location: Main.php");
                    }
				} else {
					echo 'success=false&error=login_failed';
				}
			}   
		} else {
			echo "success=false&error=login_failed";
		}
	}
?>
      
    <div class="container">
        <div class="row">
            <div class="col-sm-4"></div>
            <div class="col-sm-4">
              <form action="index.php" method="POST" class="form-signin" role="form">
                <h2 class="form-signin-heading">Please sign in</h2>
                <input type="text" name="username" class="form-control" placeholder="Username" required autofocus/>
                <input type="password" name="password" class="form-control" placeholder="Password" required/>
                <div class="checkbox">
                  <label>
                    <input type="checkbox" value="remember-me"> Remember me
                  </label>
                </div>
                <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
              </form>
            </div>
        </div>
    </div> <!-- /container -->


    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="js/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>