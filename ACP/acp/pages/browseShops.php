<div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">Shops</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <a href="Main.php?div=addShops">Add shop</a>
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered table-hover" id="dataTables-example">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Shop name</th>
                                            <th>Contents</th>
                                            <th>Access</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        
                                        <?php
		$stmt = $db->prepare('SELECT * FROM shops ORDER BY id ASC');
		$stmt->execute();

		$result = $stmt->fetchAll();
			foreach($result as $row) {
                $item = explode(",", $row["shopContents"]);
                
				echo "<tr>";
                echo "<td>".$row["id"]."</td>";
                echo "<td><a href='Main.php?div=editShop&ien=".$row["id"]."'>".$row["shopName"]."</a></td>";
                
                echo "<td>";
                foreach($item as $itm){
                    $stmt2 = $db->prepare('SELECT * FROM items WHERE id=:id');
                    $stmt2->execute(array(':id'=>$itm));

                    $result2 = $stmt2->fetchAll();
                    foreach($result2 as $row2) {
                        echo $row2["name"]."<br/>";
                    }
                }
                echo "</td>";
                echo "<td>".$row["access"]."</td>";
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