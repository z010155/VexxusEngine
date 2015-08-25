<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">Search for da uzers</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
<div class="row">
<?php
if($_POST){
?>
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Here are all teh users u seerched for brah
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered table-hover" id="dataTables-example">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Username</th>
                                            <th>Level</th>                                                             </tr>
                                    </thead>
                                    <tbody>
                                        
                                        <?php
		$stmt = $db->prepare('SELECT * FROM characters WHERE username LIKE "%'.$_POST["username"].'%" ORDER BY id ASC');
		$stmt->execute();

		$result = $stmt->fetchAll();
            if(empty($result)){
                echo "<tr><td>#</td><td>No matches found</td><td>#</td></tr>";
            }
			foreach($result as $row) {
				echo "<tr>";
                echo "<td>".$row["id"]."</td>";
                echo "<td><a href='Main.php?div=editUser&ien=".$row["id"]."'>".$row["username"]."</a></td>";
                echo "<td>".$row["level"]."</td>";
                echo "</tr>";
            }
                    ?>
					
                                    </tbody>
                                </table>
                            </div>
                            <!-- /.table-responsive -->
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
<?php
} else {
?>
<div class="col-lg-8">
                    <form method="POST" action="Main.php?div=searchUsers">
                                        <div class="form-group input-group">
                                            <input type="text" name="username" class="form-control" placeholder="Username">
                                            <span class="input-group-btn">
                                                <button class="btn btn-default" type="submit"><i class="fa fa-search"></i>
                                                </button>
                                            </span>
                                        </div>
                        </form>
</div>
<?php
}
?>
    </div>