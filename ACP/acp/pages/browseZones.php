<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">Zones</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Friend zone [x]
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered table-hover" id="dataTables-example">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Name</th>
                                            <th>Max users</th>
                                            <th>PvP enabled</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        
                                        <?php
		$stmt = $db->prepare('SELECT * FROM zones ORDER BY id ASC');
		$stmt->execute();

		$result = $stmt->fetchAll();
            if(empty($result)){
                echo "<tr><td>#</td><td>No zones?</td><td>#</td><td>#</td></tr>";
            }
			foreach($result as $row) {
				echo "<tr>";
                echo "<td>".$row["id"]."</td>";
                echo "<td><a href='Main.php?div=editZone&ien=".$row["id"]."'>".$row["zoneName"]."</a></td>";
                echo "<td>".$row["maxUsers"]."</td>";
                echo "<td>".($row["isPvP"] == 1 ? 'True': 'False')."</td>";
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