<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">ABUSERZ</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Here are all teh banned users, sir
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
		$stmt = $db->prepare('SELECT * FROM characters WHERE access="0" ORDER BY id ASC');
		$stmt->execute();

		$result = $stmt->fetchAll();
            if(empty($result)){
                echo "<tr><td>#</td><td>No banned members</td><td>#</td></tr>";
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
                <!-- /.col-lg-12 -->
            </div>