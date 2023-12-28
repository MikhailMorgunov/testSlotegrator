import os
import argparse
import subprocess
import datetime

def create_backup(source_dir, destination_dir):
    subprocess.run(['cp', '-r', source_dir, destination_dir])

def rotate_backups(backup_dir, max_backups):
    backups = sorted(os.listdir(backup_dir), key=lambda x: os.path.getmtime(os.path.join(backup_dir, x)))

    while len(backups) > max_backups:
        oldest_backup = backups.pop(0)
        subprocess.run(['rm', '-r', os.path.join(backup_dir, oldest_backup)])

def main():
    parser = argparse.ArgumentParser(description='Backup script')
    parser.add_argument('source_dir', help='Source directory to backup')
    parser.add_argument('destination_dir', help='Destination directory for backups')
    parser.add_argument('--user', default='user', help='Username for the remote server')
    parser.add_argument('--server', required=True, help='IP address of the remote server')
    parser.add_argument('--debug', action='store_true', help='Enable debug mode')
    parser.add_argument('--remote_dirs', nargs='+', default=['/'], help='Remote directories to backup')
    parser.add_argument('--full_backup', action='store_true', help='Perform a full backup')
    parser.add_argument('--max_backups', type=int, default=2, help='Maximum number of backups to keep')

    args = parser.parse_args()

    if args.debug:
        print(f'Debug mode is enabled: {args}')

    timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    backup_folder = f'{timestamp}_Full' if args.full_backup else f'{timestamp}_Inc'
    backup_path = os.path.join(args.destination_dir, backup_folder)

    create_backup(args.source_dir, backup_path)

    rotate_backups(args.destination_dir, args.max_backups)

if __name__ == '__main__':
    main()
