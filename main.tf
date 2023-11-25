module "vpc" {
  source           = "./modules/vpc"
  application_name = local.application_name
}

# module "ec2" {
#   source           = "./modules/ec2"
#   application_name = local.application_name
#   public_subnet_a  = module.vpc.subnet_a_id //pegando o id da subrede
#   public_subnet_b  = module.vpc.subnet_b_id //pegando o id da subrede
#   vpc_id           = module.vpc.vpc_id      //pegando o id da vpc
# }

# module "alb" {
#   source           = "./modules/alb"
#   application_name = local.application_name
#   vpc_id           = module.vpc.vpc_id
#   public_subnet_ids   = [module.vpc.subnet_a_id, module.vpc.subnet_b_id]
# }

module "iam" {
  source           = "./modules/iam"
  application_name = local.application_name
  
}
module "asg" {
   source = "./modules/asg"
    application_name = local.application_name
    vpc_id           = module.vpc.vpc_id
    public_subnets   = [module.vpc.public_subnet_a_id, module.vpc.public_subnet_b_id]
    db_host          = module.rds.db_host
    profile_name     = module.iam.profile_name
    private_subnet_a_id = module.vpc.private_subnet_a_id
    private_subnet_b_id = module.vpc.private_subnet_b_id
    public_subnet_a_id = module.vpc.public_subnet_a_id
    project_db = module.rds.project_db
}

module "rds" {
  source           = "./modules/rds"
  vpc_id = module.vpc.vpc_id
  application_name = local.application_name
  private_subnet_a = module.vpc.private_subnet_a_id
  private_subnet_b = module.vpc.private_subnet_b_id
}